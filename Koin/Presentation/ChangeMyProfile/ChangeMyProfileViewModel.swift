//
//  ChangeMyProfileViewModel.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//


import Combine

final class ChangeMyProfileViewModel: ViewModelProtocol {
    
    enum Input {
        case fetchUserData
        case fetchDeptList
        case modifyProfile(UserPutRequest)
    }
    enum Output {
        case showToast(String, Bool)
        case showProfile(UserDTO)
        case showDeptDropDownList([String])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let modifyUseCase: ModifyUseCase
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    
    init(modifyUseCase: ModifyUseCase, fetchDeptListUseCase: FetchDeptListUseCase, fetchUserDataUseCase: FetchUserDataUseCase) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.modifyUseCase = modifyUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
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
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChangeMyProfileViewModel {
    
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showProfile(response))
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
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("회원 정보 수정이 완료되었습니다.", true))
        }.store(in: &subscriptions)

    }

}
