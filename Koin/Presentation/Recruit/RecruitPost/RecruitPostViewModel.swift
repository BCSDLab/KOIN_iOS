//
//  RecruitPostViewModel.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Foundation
import Combine

final class RecruitPostViewModel: ViewModelProtocol {
    
    enum PostType {
        case post
        case modify(data: RecruitData)
    }
    
    enum Input {
        case viewDidLoad
        case submit(RecruitPostRequest)
    }
    enum Output {
        case updateLoading(Bool)
        case updateForm(RecruitPostRequest)
        
        case postFailed
        case postCompleted(id: Int)
        case modifyCompleted(id: Int)
        case showToast(String)
    }
    
    // MARK: - Properties
    private let postRecruitUseCase: PostRecruitUseCase
    private let modifyRecruitUseCase: ModifyRecruitUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    let postType: PostType
    
    // MARK: - Initializer
    init(
        postType: PostType,
        postRecruitUseCase: PostRecruitUseCase,
        modifyRecruitUseCase: ModifyRecruitUseCase,
    ) {
        self.postType = postType
        self.postRecruitUseCase = postRecruitUseCase
        self.modifyRecruitUseCase = modifyRecruitUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                applyDataIfModifying()
            case let .submit(form):
                submit(form)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RecruitPostViewModel {
    
    private func applyDataIfModifying() {
        guard case let .modify(data) = postType else {
            return
        }
        outputSubject.send(.updateForm(.init(from: data)))
    }
}

extension RecruitPostViewModel {
    
    private func submit(_ request: RecruitPostRequest) {
        outputSubject.send(.updateLoading(true))
        
        Task {
            do {
                defer {
                    outputSubject.send(.updateLoading(false))
                }
                switch postType {
                case .post:
                    let id = try await postRecruitUseCase.execute(request: request)
                    outputSubject.send(.postCompleted(id: id))
                case let .modify(data):
                    try await modifyRecruitUseCase.execute(id: data.id, request: request)
                    outputSubject.send(.modifyCompleted(id: data.id))
                }
            } catch {
                outputSubject.send(.postFailed)
                if let error = error as? ErrorResponse {
                    outputSubject.send(.showToast(error.message))
                }
            }
        }
    }
}
