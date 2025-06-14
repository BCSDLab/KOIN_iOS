//
//  RegisterFormViewModel.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import Combine

final class RegisterFormViewModel: ViewModelProtocol {
    var tempName: String?
    var tempPhoneNumber: String?
    var tempGender: String? // "0" = 남성, "1" = 여성
    private(set) var userType: UserType?

    func selectUserType(_ type: UserType) {
        self.userType = type
    }
    
    // FIXME: - 로그 확인용 지우기
    func logCurrentState(tag: String = "💡ViewModel 상태") {
        print("""
        \(tag)
        tempName: \(tempName ?? "nil")
        tempPhoneNumber: \(tempPhoneNumber ?? "nil")
        tempGender: \(tempGender ?? "nil")
        userType: \(userType.map { "\($0)" } ?? "nil")
        """)
    }
    
    var outputPublisher: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }
    
    enum UserType {
        case student, general
    }

    enum Input {
        case checkDuplicatedPhoneNumber(String)
        case sendVerificationCode(String)
        case checkVerificationCode(String, String)
        case checkDuplicatedId(String)
        case getDeptList
        case checkDuplicatedNickname(String)
        case tryStudentRegister(StudentRegisterFormRequest)
        case tryGeneralRegister(GeneralRegisterFormRequest)
    }
    
    enum Output {
        case showHttpResult(String, SceneColorAsset)
        case showIdHttpResult(String, SceneColorAsset)
        case showNicknameHttpResult(String, SceneColorAsset)
        case changeSendVerificationButtonStatus
        case sendVerificationCodeSuccess(response: SendVerificationCodeDTO)
        case correctVerificationCode
        case successCheckDuplicatedId
        case showDeptDropDownList([String])
        case changeCheckButtonStatus
        case succesRegister
        case showUserType(UserType)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase
    private let sendVerificationCodeUseCase: SendVerificationCodeUsecase
    private let checkVerificationCodeUseCase: CheckVerificationCodeUsecase
    private let checkDuplicatedIdUseCase: CheckDuplicatedIdUsecase
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase
    private let registerFormUseCase: RegisterFormUseCase

    init(checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase, sendVerificationCodeUseCase: SendVerificationCodeUsecase, checkVerificationCodeUseCase: CheckVerificationCodeUsecase, checkDuplicatedIdUseCase: CheckDuplicatedIdUsecase, fetchDeptListUseCase: FetchDeptListUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase, registerFormUseCase: RegisterFormUseCase) {
        self.checkDuplicatedPhoneNumberUseCase = checkDuplicatedPhoneNumberUseCase
        self.sendVerificationCodeUseCase = sendVerificationCodeUseCase
        self.checkVerificationCodeUseCase = checkVerificationCodeUseCase
        self.checkDuplicatedIdUseCase = checkDuplicatedIdUseCase
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
        self.registerFormUseCase = registerFormUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .checkDuplicatedPhoneNumber(phone):
                self?.checkDuplicatedPhoneNumber(phone: phone)
            case let .sendVerificationCode(phoneNumber):
                self?.sendVerificationCode(phoneNumber: phoneNumber)
            case let .checkVerificationCode(phoneNumber, verificationCode):
                self?.checkVerificationCode(phoneNumber: phoneNumber, verificationCode: verificationCode)
            case let .checkDuplicatedId(loginId):
                self?.checkDuplicatedId(loginId: loginId)
            case .getDeptList:
                self?.fetchDeptList()
            case let .checkDuplicatedNickname(nickname):
                self?.checkDuplicatedNickname(nickname: nickname)
            case let .tryStudentRegister(request):
                self?.studentRegister(registerRequest: request)
            case let .tryGeneralRegister(request):
                self?.generalRegister(registerRequest: request)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    private func checkDuplicatedPhoneNumber(phone: String) {
        checkDuplicatedPhoneNumberUseCase.execute(phone: phone).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .sub500))
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.changeSendVerificationButtonStatus)
        }
        .store(in: &subscriptions)
    }
    
    private func sendVerificationCode(phoneNumber: String) {
        sendVerificationCodeUseCase.execute(request: SendVerificationCodeRequest(phoneNumber: phoneNumber))
            .sink { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.outputSubject.send(.showHttpResult(error.message, .sub500))
                }
            } receiveValue: { [weak self] response in
                self?.outputSubject.send(.sendVerificationCodeSuccess(response: response))
            }
            .store(in: &subscriptions)
    }
    
    private func checkVerificationCode(phoneNumber: String, verificationCode: String) {
        checkVerificationCodeUseCase.execute(phoneNumber: phoneNumber, verificationCode: verificationCode).sink { [weak self] completion in
            if case let .failure(error) = completion {
                if let code = Int(error.code) {
                    if code == 400 {
                        self?.outputSubject.send(.showHttpResult(error.message, .sub500))
                    } else if code == 404 {
                        self?.outputSubject.send(.showHttpResult(error.message, .danger700))
                    }
                } else {
                    self?.outputSubject.send(.showHttpResult(error.message, .sub500))
                }
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.correctVerificationCode)
        }
        .store(in: &subscriptions)
    }
    
    private func checkDuplicatedId(loginId: String) {
        checkDuplicatedIdUseCase.execute(loginId: loginId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showIdHttpResult(error.message, .sub500))
            }
        } receiveValue: { [weak self] (_: Void) in
            self?.outputSubject.send(.successCheckDuplicatedId)
        }
        .store(in: &subscriptions)
    }

    private func fetchDeptList() {
        fetchDeptListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showDeptDropDownList(response))
        }.store(in: &subscriptions)
    }
    
    private func checkDuplicatedNickname(nickname: String) {
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showHttpResult(error.message, .danger700))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.changeCheckButtonStatus)
        }.store(in: &subscriptions)
    }
    
    private func studentRegister(registerRequest: StudentRegisterFormRequest) {
        registerFormUseCase.studentExecute(
            name: registerRequest.name,
            phoneNumber: registerRequest.phoneNumber,
            loginId: registerRequest.loginId,
            password: registerRequest.password,
            department: registerRequest.department,
            studentNumber: registerRequest.studentNumber,
            gender: registerRequest.gender,
            email: registerRequest.email?.isEmpty == true ? nil : "\(registerRequest.email!)@koreatech.ac.kr",
            nickname: registerRequest.nickname?.isEmpty == true ? nil : registerRequest.nickname
        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                print("❌ 학생 회원가입 실패: \(error.message), code: \(error.code)")
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.succesRegister)
        }.store(in: &subscriptions)
    }

    private func generalRegister(registerRequest: GeneralRegisterFormRequest) {
        registerFormUseCase.generalExecute(
            name: registerRequest.name,
            phoneNumber: registerRequest.phoneNumber,
            loginId: registerRequest.loginId,
            gender: registerRequest.gender,
            password: registerRequest.password,
            email: registerRequest.email?.isEmpty == true ? nil : registerRequest.email,
            nickname: registerRequest.nickname?.isEmpty == true ? nil : registerRequest.nickname

        )
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                print("❌ 외부인 회원가입 실패: \(error.message), code: \(error.code)")
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.succesRegister)
        }.store(in: &subscriptions)
    }

}
