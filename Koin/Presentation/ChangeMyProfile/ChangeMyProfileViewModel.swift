//
//  ChangeMyProfileViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//


import Combine

final class ChangeMyProfileViewModel: ViewModelProtocol {
    
    enum Request {
        case nickname
        case save
    }
    enum Input {
        case modifyProfile(UserPutRequest)
    }
    enum Output {
        case showToastMessage(String, Bool)
        case showToast(String, Bool, Request)
        case showProfile(UserDTO)
        case showDeptDropDownList([String])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let modifyUseCase: ModifyUseCase
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase
    private let userRepository = DefaultUserRepository(service: DefaultUserService())
    private lazy var sendVerificationCodeUseCase = DefaultSendVerificationCodeUseCase(userRepository: userRepository)
    private lazy var checkVerificationCodeUseCase = DefaultCheckVerificationCodeUsecase(userRepository: userRepository)
    private lazy var revokeUseCase = DefaultRevokeUseCase(userRepository: userRepository)
    
    private(set) var userData: UserDTO? = nil
    @Published var modifyUserData: UserDTO? = nil
    
    @Published var phoneNumberSuccess: Bool = true
    @Published var nicknameSuccess: Bool = true
    @Published private(set) var isFormValid: Bool = false
    
    let nicknameMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let phoneNumberMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    let certNumberMessagePublisher = PassthroughSubject<(String, Bool), Never>()
    
    init(modifyUseCase: ModifyUseCase, fetchDeptListUseCase: FetchDeptListUseCase, fetchUserDataUseCase: FetchUserDataUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.modifyUseCase = modifyUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
        bind()
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .modifyProfile(request):
                self?.modifyProfile(request: request)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChangeMyProfileViewModel {
    func revoke() {
        revokeUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToastMessage(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToastMessage("회원탈퇴가 완료되었습니다.", true))
            UserDataManager.shared.resetUserData()
        }.store(in: &subscriptions)
    }
    
    func sendVerificationCode(phoneNumber: String) {
        sendVerificationCodeUseCase.execute(request: .init(phoneNumber: phoneNumber)).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.phoneNumberMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] _ in
            self?.phoneNumberMessagePublisher.send(("인증번호가 발송되었습니다.", true))
        }.store(in: &subscriptions)
    }
    
    func checkVerificationCode(phoneNumber: String, code: String) {
        checkVerificationCodeUseCase.execute(phoneNumber: phoneNumber, verificationCode: code).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.certNumberMessagePublisher.send((error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.certNumberMessagePublisher.send(("인증번호가 일치합니다.", true))
            self?.modifyUserData?.phoneNumber = phoneNumber
            self?.phoneNumberSuccess = true
        }.store(in: &subscriptions)
    }
    
    func checkDuplicatedNickname(nickname: String) {
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                if nickname == self?.userData?.nickname {
                    
                } else {
                    self?.nicknameMessagePublisher.send((error.message, false))
                }
            }
        } receiveValue: { [weak self] response in
            self?.nicknameMessagePublisher.send(("사용 가능한 닉네임입니다.", true))
            self?.modifyUserData?.nickname = nickname
            self?.nicknameSuccess = true
        }.store(in: &subscriptions)
    }
    
    func fetchUserData() {
        fetchUserDataUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showProfile(response))
            self?.userData = response
            self?.modifyUserData = response
        }.store(in: &subscriptions)
    }
    
    func fetchDeptList() {
        fetchDeptListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showDeptDropDownList(response))
        }.store(in: &subscriptions)
    }
    
    private func modifyProfile(request: UserPutRequest) {
        modifyUseCase.execute(requestModel: request).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false, .save))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("회원 정보 수정이 완료되었습니다.", true, .save))
            self?.userData = response
            UserDataManager.shared.setUserData(userData: response)
        }.store(in: &subscriptions)
        
    }
    private func bind() {
        Publishers.CombineLatest3($modifyUserData, $phoneNumberSuccess, $nicknameSuccess)
            .map { [weak self] modified, emailOK, nicknameOK in
                guard let original = self?.userData else { return false }
                return emailOK && nicknameOK && original != modified
            }
            .assign(to: &$isFormValid)
    }
}
