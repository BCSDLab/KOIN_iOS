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
        case modify(id: Int)
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
    private let fetchRecruitDataUseCase: FetchRecruitDataUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    let postType: PostType
    
    // MARK: - Initializer
    init(
        postType: PostType,
        postRecruitUseCase: PostRecruitUseCase,
        modifyRecruitUseCase: ModifyRecruitUseCase,
        fetchRecruitDataUseCase: FetchRecruitDataUseCase
    ) {
        self.postType = postType
        self.postRecruitUseCase = postRecruitUseCase
        self.modifyRecruitUseCase = modifyRecruitUseCase
        self.fetchRecruitDataUseCase = fetchRecruitDataUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchFormIfNeeded()
            case let .submit(form):
                submit(form)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension RecruitPostViewModel {
    
    private func fetchFormIfNeeded() {
        guard case let .modify(id) = postType else {
            return
        }
        
        Task {
            outputSubject.send(.updateLoading(true))
            defer {
                outputSubject.send(.updateLoading(false))
            }
            
            do {
                let data = try await fetchRecruitDataUseCase.execute(id: id)
                outputSubject.send(.updateForm(.init(from: data)))
            } catch {
                if let error = error as? ErrorResponse {
                    outputSubject.send(.showToast(error.message))
                }
            }
        }
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
                case let .modify(id):
                    try await modifyRecruitUseCase.execute(id: id, request: request)
                    outputSubject.send(.modifyCompleted(id: id))
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
