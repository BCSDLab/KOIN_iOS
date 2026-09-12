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
        case edit(id: Int)
    }
    
    enum Input {
        case viewDidLoad
        case submit(RecruitPostRequest)
    }
    enum Output {
        case updateLoading(Bool)
        case updateForm(RecruitPostRequest)
        
        case submitFailed
        case submitCompleted(id: Int?)
        case showToast(String)
    }
    
    // MARK: - Properties
    private let postRecruitUseCase: PostRecruitUseCase
    private let modifyRecruitUseCase: ModifyRecruitUseCase
    private let fetchRecruitDetailUseCase: FetchRecruitDetailUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    let postType: PostType
    
    // MARK: - Initializer
    init(
        postType: PostType,
        postRecruitUseCase: PostRecruitUseCase,
        modifyRecruitUseCase: ModifyRecruitUseCase,
        fetchRecruitDetailUseCase: FetchRecruitDetailUseCase
    ) {
        self.postType = postType
        self.postRecruitUseCase = postRecruitUseCase
        self.modifyRecruitUseCase = modifyRecruitUseCase
        self.fetchRecruitDetailUseCase = fetchRecruitDetailUseCase
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
        guard case let .edit(id) = postType else {
            return
        }
        
        Task {
            outputSubject.send(.updateLoading(true))
            defer {
                outputSubject.send(.updateLoading(false))
            }
            
            do {
                let detail = try await fetchRecruitDetailUseCase.execute(id: id)
                outputSubject.send(.updateForm(.init(from: detail)))
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
                    outputSubject.send(.submitCompleted(id: id))
                case let .edit(id):
                    try await modifyRecruitUseCase.execute(id: id, request: request)
                    outputSubject.send(.submitCompleted(id: id))
                }
            } catch {
                outputSubject.send(.submitFailed)
                if let error = error as? ErrorResponse {
                    outputSubject.send(.showToast(error.message))
                }
            }
        }
    }
}
