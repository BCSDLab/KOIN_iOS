//
//  MyPageViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/19/24.
//

import Combine

final class MyPageViewModel: ViewModelProtocol {
    
    enum Input {
        case getDeptList
        case tryModifyProfile(UserPutRequest, String)
        case tryRevokeProfile
        case fetchUserData
        case checkNickname(String)
    }
    enum Output {
        case modifySuccess
        case showHttpResult(String, SceneColorAsset)
        case loginAgain
        case revokeSuccess
        case changeCheckButtonStatus
        case showDeptDropDownList([String])
        case showUserProfile(UserDTO)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let modifyUseCase: ModifyUseCase
    private let revokeUseCase: RevokeUseCase
    private let checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var userNickname: String? = ""
    
    init(fetchDeptListUseCase: FetchDeptListUseCase, fetchUserDataUseCase: FetchUserDataUseCase, modifyUseCase: ModifyUseCase, revokeUseCase: RevokeUseCase, checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.modifyUseCase = modifyUseCase
        self.revokeUseCase = revokeUseCase
        self.checkDuplicatedNicknameUseCase = checkDuplicatedNicknameUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getDeptList:
                self?.getDeptList()
            case let .tryModifyProfile(userProfile, passwordMatchText):
                self?.tryModifyProfile(userProfile, passwordMatchText)
            case let .checkNickname(nickName):
                self?.checkDuplicatedNickname(nickName)
            case .tryRevokeProfile:
                self?.tryRevokeProfile()
            case .fetchUserData:
                self?.fetchUserData()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension MyPageViewModel {
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.loginAgain)
            }
        } receiveValue: { [weak self] response in
            self?.userNickname = response.nickname
            self?.outputSubject.send(.showUserProfile(response))
        }.store(in: &subscriptions)
    }
    
    private func getDeptList() {
        fetchDeptListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showDeptDropDownList(response))
        }.store(in: &subscriptions)
    }
    
    // TODO: 이거 비밀번호 확인에만 문구가 있을 경우에 대한 예외 처리 추가 필요
    private func tryModifyProfile(_ profile: UserPutRequest, _ passwordMatch: String) {
        modifyUseCase.execute(requestModel: profile).sink { [weak self] completion in
            if case let .failure(error) = completion {
                switch error.code {
                case "401" : self?.outputSubject.send(.loginAgain)
                default: self?.outputSubject.send(.showHttpResult(error.message, .danger700))
                }
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.modifySuccess)
        }.store(in: &subscriptions)
    }
    
    private func tryRevokeProfile() {
        revokeUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                switch error.code {
                case "401" : self?.outputSubject.send(.loginAgain)
                default: self?.outputSubject.send(.showHttpResult(error.message, .danger700))
                }
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.revokeSuccess)
        }.store(in: &subscriptions)
    }
    
    private func checkDuplicatedNickname(_ nickname: String) {
        if nickname == userNickname {
            outputSubject.send(.showHttpResult("사용 가능한 닉네임입니다.", .neutral800))
            outputSubject.send(.changeCheckButtonStatus)
            return
        }
        
        checkDuplicatedNicknameUseCase.execute(nickname: nickname).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showHttpResult(error.message, .danger700))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showHttpResult("사용 가능한 닉네임입니다.", .neutral800))
            self?.outputSubject.send(.changeCheckButtonStatus)
        }.store(in: &subscriptions)
    }
}
