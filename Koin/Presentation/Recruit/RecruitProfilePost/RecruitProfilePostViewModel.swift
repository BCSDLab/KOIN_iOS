//
//  RecruitProfilePostViewController.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Combine
import Foundation

final class RecruitProfilePostViewModel: ViewModelProtocol {

    enum Mode {
        case post
        case modify(RecruitProfile)
    }

    enum Input {
        case viewDidLoad
        case loadUserData
        case submit(basicInfo: BasicInfo, request: RecruitProfileRequest)
    }

    enum Output {
        case updateBasicInfo(BasicInfo)
        case updateDepartments([String])
        case updateLoading(Bool)
        case postCompleted(RecruitProfile)
        case showToast(String)
    }

    // MARK: - State
    let mode: Mode

    // MARK: - UseCase
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let postBasicInfoUseCase: PostBasicInfoUseCase
    private let postRecruitProfileUseCase: PostRecruitProfileUseCase

    // MARK: - Publisher
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var isSubmitting = false

    // MARK: - Initializer
    init(
        fetchDeptListUseCase: FetchDeptListUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase,
        postBasicInfoUseCase: PostBasicInfoUseCase,
        postRecruitProfileUseCase: PostRecruitProfileUseCase,
        mode: Mode
    ) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.postBasicInfoUseCase = postBasicInfoUseCase
        self.postRecruitProfileUseCase = postRecruitProfileUseCase
        self.mode = mode
    }

    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchDepartments()
            
                switch mode {
                case .post:
                    return
                case .modify(let recruitProfile):
                    let basicInfo = recruitProfile.toBasicInfo()
                    self.outputSubject.send(.updateBasicInfo(basicInfo))
                }
            case .loadUserData:
                fetchUserData()
            case let .submit(basicInfo, request):
                submit(basicInfo: basicInfo, request: request)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RecruitProfilePostViewModel {
    private func fetchDepartments() {
        fetchDeptListUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case let .failure(error) = completion else { return }
                    self?.outputSubject.send(.showToast(error.message))
                },
                receiveValue: { [weak self] departments in
                    self?.outputSubject.send(.updateDepartments(departments))
                }
            )
            .store(in: &subscriptions)
    }

    private func fetchUserData() {
        fetchUserDataUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case let .failure(error) = completion else { return }
                    self?.outputSubject.send(.showToast(error.message))
                },
                receiveValue: { [weak self] user in
                    guard let self else { return }
                    self.outputSubject.send(.updateBasicInfo(.init(
                        nickname: user.nickname ?? user.anonymousNickname,
                        department: user.major,
                        studentNumber: user.studentNumber
                    )))
                }
            )
            .store(in: &subscriptions)
    }

    private func submit(
        basicInfo: BasicInfo,
        request: RecruitProfileRequest
    ) {
        guard !isSubmitting else { return }

        isSubmitting = true
        outputSubject.send(.updateLoading(true))

        Task {
            do {
                _ = try await postBasicInfoUseCase.execute(basicInfo: basicInfo)
                let profile = try await postRecruitProfileUseCase.execute(request: request)
                isSubmitting = false
                outputSubject.send(.updateLoading(false))
                outputSubject.send(.postCompleted(profile))
            } catch {
                isSubmitting = false
                outputSubject.send(.updateLoading(false))
                let message = (error as? ErrorResponse)?.message ?? "프로필 저장에 실패했습니다."
                outputSubject.send(.showToast(message))
            }
        }
    }
}
