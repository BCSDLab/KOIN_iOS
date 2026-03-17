//
//  CallVanChatViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import Foundation
import Combine

final class CallVanChatViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case viewWillAppear
        case viewWillDisappear
        case sendMessage(String)
        case sendImage(Data)
    }
    enum Output {
        case update(CallVanChat)
        case showToast(String)
        case updateData(CallVanData)
    }
    
    // MARK: - Properties
    private let fetchCallVanChatUseCase: FetchCallVanChatUseCase
    private let postCallVanChatUseCase: PostCallVanChatUseCase
    private let fetchCallVanDataUseCase: FetchCallVanDataUseCase
    private let uploadFileUseCase: UploadFileUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var pollingSubscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    let postId: Int
    
    // MARK: - Initializer
    init(postId: Int,
         fetchCallVanChatUseCase: FetchCallVanChatUseCase,
         postCallVanChatUseCase: PostCallVanChatUseCase,
         fetchCallVanDataUseCase: FetchCallVanDataUseCase,
         uploadFileUseCase: UploadFileUseCase) {
        self.postId = postId
        self.fetchCallVanChatUseCase = fetchCallVanChatUseCase
        self.postCallVanChatUseCase = postCallVanChatUseCase
        self.fetchCallVanDataUseCase = fetchCallVanDataUseCase
        self.uploadFileUseCase = uploadFileUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchData()
            case .viewWillAppear:
                startPolling()
            case .viewWillDisappear:
                stopPolling()
            case let .sendMessage(message):
                postCallVanChat(CallVanChatRequest(isImage: false, content: message))
            case let .sendImage(imageData):
                uploadImage(imageData)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanChatViewModel {
    
    private func startPolling() {
        pollingSubscription?.cancel()
        pollingSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .map { [weak self] _ -> AnyPublisher<CallVanChat, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return fetchCallVanChatUseCase.execute(postId: postId)
                    .catch { error -> AnyPublisher<CallVanChat, Never> in
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] callVanChat in
                self?.outputSubject.send(.update(callVanChat))
            }
    }
    
    private func stopPolling() {
        pollingSubscription?.cancel()
        pollingSubscription = nil
    }
    
    private func postCallVanChat(_ request: CallVanChatRequest) {
        postCallVanChatUseCase.execute(postId: postId, request: request).sink(
            receiveCompletion: { [weak self] comepltion in
                if case .failure(let error) = comepltion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] in
                self?.stopPolling()
                self?.startPolling()
            }
        ).store(in: &subscriptions)
    }
    
    private func uploadImage(_ imageData: Data) {
        uploadFileUseCase.execute(files: [imageData], domain: .callVanChat).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] response in
                if let imageUrl = response.fileUrls.first {
                    let request = CallVanChatRequest(isImage: true, content: imageUrl)
                    self?.postCallVanChat(request)
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func fetchData() {
        fetchCallVanDataUseCase.execute(postId: postId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanData in
                self?.outputSubject.send(.updateData(callVanData))
            }
        ).store(in: &subscriptions)
    }
}
