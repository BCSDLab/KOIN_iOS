//
//  RecruitApplyViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Combine
import Foundation

final class RecruitApplyViewModel: ViewModelProtocol {

    enum Input {
        case viewDidLoad
        case loadRecruitProfile
        case apply(RecruitApplyRequest)
    }

    enum Output {
        case updateRecruitProfile(RecruitProfile)
        case updateDepartments([String])
        case applyCompleted
        case showToast(String)
    }

    // MARK: - Properties
    private let fetchDeptListUseCase: FetchDeptListUseCase
    private let fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase
    private let applyRecruitUseCase: ApplyRecruitUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var isLoadingProfile = false
    private var isApplying = false

    // MARK: - Initializer
    init(
        fetchDeptListUseCase: FetchDeptListUseCase,
        fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase,
        applyRecruitUseCase: ApplyRecruitUseCase
    ) {
        self.fetchDeptListUseCase = fetchDeptListUseCase
        self.fetchMyRecruitProfileUseCase = fetchMyRecruitProfileUseCase
        self.applyRecruitUseCase = applyRecruitUseCase
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] input in
                switch input {
                case .viewDidLoad:
                    self?.fetchDepartments()
                case .loadRecruitProfile:
                    self?.fetchRecruitProfile()
                case let .apply(request):
                    self?.apply(request)
                }
            }
            .store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension RecruitApplyViewModel {
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

    private func fetchRecruitProfile() {
        guard !isLoadingProfile else { return }

        isLoadingProfile = true
        Task { [weak self] in
            guard let self else { return }
            defer { isLoadingProfile = false }

            do {
                guard let profile = try await fetchMyRecruitProfileUseCase.execute() else {
                    let message = "프로필을 불러오지 못했습니다."
                    outputSubject.send(.showToast(message))
                    return
                }
                outputSubject.send(.updateRecruitProfile(profile))
            } catch {
                let message = (error as? ErrorResponse)?.message ?? "프로필을 불러오지 못했습니다."
                outputSubject.send(.showToast(message))
            }
        }
    }

    private func apply(_ request: RecruitApplyRequest) {
        guard !isApplying else { return }

        isApplying = true
        Task { [weak self] in
            guard let self else { return }
            defer { isApplying = false }

            do {
                try await applyRecruitUseCase.execute(request: request)
                outputSubject.send(.applyCompleted)
            } catch {
                let errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
                outputSubject.send(.showToast(errorMessage))
            }
        }
    }
}
