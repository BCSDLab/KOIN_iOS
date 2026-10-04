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
        case fetchBasicInfo
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
    private let fetchBasicInfoUseCase: FetchBasicInfoUseCase
    private let modifyBasicInfoUseCase: ModifyBasicInfoUseCase
    private let upsertMyRecruitProfileUseCase: UpsertMyRecruitProfileUseCase

    // MARK: - Publisher
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var isSubmitting = false

    // MARK: - Initializer
    init(
        fetchDeptListUseCase: FetchDeptListUseCase,
        fetchBasicInfoUseCase: FetchBasicInfoUseCase,
        modifyBasicInfoUseCase: ModifyBasicInfoUseCase,
        upsertMyRecruitProfileUseCase: UpsertMyRecruitProfileUseCase,
        mode: Mode
    ) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.fetchBasicInfoUseCase = fetchBasicInfoUseCase
        self.modifyBasicInfoUseCase = modifyBasicInfoUseCase
        self.upsertMyRecruitProfileUseCase = upsertMyRecruitProfileUseCase
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
            case .fetchBasicInfo:
                fetchBasicInfo()
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

    private func fetchBasicInfo() {
        Task {
            do {
                let basicInfo = try await fetchBasicInfoUseCase.execute()
                outputSubject.send(.updateBasicInfo(basicInfo))
            } catch {
                let message = (error as? ErrorResponse)?.message ?? error.localizedDescription
                outputSubject.send(.showToast(message))
            }
        }
    }

    private func submit(
        basicInfo: BasicInfo,
        request: RecruitProfileRequest
    ) {
        guard !isSubmitting else { return }
        Task {
            isSubmitting = true
            outputSubject.send(.updateLoading(true))
            defer {
                isSubmitting = false
                outputSubject.send(.updateLoading(false))
            }
            do {
                var request = request
                request.nickname = basicInfo.nickname
                try await modifyBasicInfoUseCase.execute(basicInfo: basicInfo)
                let profile = try await upsertMyRecruitProfileUseCase.execute(request: request)
                outputSubject.send(.postCompleted(profile))
            } catch {
                let message = (error as? ErrorResponse)?.message ?? error.localizedDescription
                outputSubject.send(.showToast(message))
            }
        }
    }
}
