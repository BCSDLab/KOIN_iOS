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
        case fetchUserData
        case fetchDeptList
        case modifyProfile(UserPutRequest)
        case checkNickname(String)
    }
    enum Output {
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
    private(set) var userData: UserDTO? = nil
    
    init(modifyUseCase: ModifyUseCase, fetchDeptListUseCase: FetchDeptListUseCase, fetchUserDataUseCase: FetchUserDataUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.modifyUseCase = modifyUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchUserData:
                self?.fetchUserData()
            case .fetchDeptList:
                self?.fetchDeptList()
            case let .modifyProfile(request):
                self?.modifyProfile(request: request)
            case let .checkNickname(nickname):
                self?.checkDuplicatedNickname(nickname: nickname)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChangeMyProfileViewModel {
    
    private func checkDuplicatedNickname(nickname: String) {
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                if self?.userData?.nickname == nickname {
                    self?.outputSubject.send(.showToast("사용가능한 닉네임입니다.", true, .nickname))
                } else {
                    Log.make().error("\(error)")
                    self?.outputSubject.send(.showToast(error.message, false, .nickname))
                }
            }
        } receiveValue: { [weak self] response in
            print(response)
            self?.outputSubject.send(.showToast("사용가능한 닉네임입니다.", true, .nickname))
        }.store(in: &subscriptions)

    }
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showProfile(response))
            self?.userData = response
        }.store(in: &subscriptions)
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

}
