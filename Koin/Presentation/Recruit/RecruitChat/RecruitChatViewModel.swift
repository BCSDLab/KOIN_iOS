//
//  RecruitChatViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Combine
import Foundation

final class RecruitChatViewModel: ViewModelProtocol {

    enum RoomSource {
        case team(recruitmentId: Int, chatRoomId: Int)
        case direct(recruitmentId: Int, applicationId: Int)
    }

    enum Input {
        case viewWillAppear
        case viewDidDisappear
        case sendText(text: String)
        case sendImage(image: Data)
    }

    enum Output {
        case updateData(RecruitChatData)
        case updateMessages(RecruitChatMessageList)
        case showToast(String)
    }

    // MARK: - Properties
    private let fetchTeamChatDataUseCase: FetchRecruitTeamChatDataUseCase
    private let fetchDirectChatDataUseCase: FetchRecruitDirectChatDataUseCase
    private let fetchChatMessagesUseCase: FetchRecruitChatMessagesUseCase
    private let postChatMessageUseCase: PostRecruitChatMessageUseCase
    private let uploadFileUseCase: UploadFileUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private var pollingTask: Task<Void, Never>?
    
    private let roomSource: RoomSource
    private var chatRoomId: Int?
    private var recruitmentId: Int {
        switch roomSource {
        case let .team(recruitmentId, _), let .direct(recruitmentId, _):
            return recruitmentId
        }
    }
    private var didUpdateData = false

    // MARK: - Initializer
    init(
        roomSource: RoomSource,
        fetchTeamChatDataUseCase: FetchRecruitTeamChatDataUseCase,
        fetchDirectChatDataUseCase: FetchRecruitDirectChatDataUseCase,
        fetchChatMessagesUseCase: FetchRecruitChatMessagesUseCase,
        postChatMessageUseCase: PostRecruitChatMessageUseCase,
        uploadFileUseCase: UploadFileUseCase
    ) {
        self.roomSource = roomSource
        self.fetchTeamChatDataUseCase = fetchTeamChatDataUseCase
        self.fetchDirectChatDataUseCase = fetchDirectChatDataUseCase
        self.fetchChatMessagesUseCase = fetchChatMessagesUseCase
        self.postChatMessageUseCase = postChatMessageUseCase
        self.uploadFileUseCase = uploadFileUseCase

        if case let .team(_, chatRoomId) = roomSource {
            self.chatRoomId = chatRoomId
        }
    }

    deinit {
        stopPolling()
    }

    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] input in
                switch input {
                case .viewWillAppear:
                    self?.startPolling()
                case .viewDidDisappear:
                    self?.stopPolling()
                case .sendText(let text):
                    self?.postMessage(text: text)
                case .sendImage(let image):
                    self?.postMessage(image: image)
                }
            }
            .store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension RecruitChatViewModel {
    private func fetchChatRoomDataIfNeeded() async {
        guard !didUpdateData else {
            return
        }
        
        do {
            switch roomSource {
            case .direct(_, let applicationId):
                try await fetchDirectChatData(applicationId)
            case .team:
                try await fetchTeamChatData()
            }
            didUpdateData = true
        } catch {
            outputSubject.send(.showToast(errorMessage(from: error)))
        }
    }
    
    private func fetchDirectChatData(_ applicationId: Int) async throws {
        let chatData = try await fetchDirectChatDataUseCase.execute(
            recruitmentId: recruitmentId,
            applicationId: applicationId
        )
        self.chatRoomId = chatData.chatRoomId
        outputSubject.send(.updateData(chatData))
    }
    
    private func fetchTeamChatData() async throws {
        guard let chatRoomId else {
            throw ErrorResponse.unexpectedInternalError
        }
        
        let chatData = try await fetchTeamChatDataUseCase.execute(
            recruitmentId: recruitmentId,
            chatRoomId: chatRoomId
        )
        outputSubject.send(.updateData(chatData))
    }
}

extension RecruitChatViewModel {
    
    private func startPolling() {
        guard pollingTask == nil else {
            return
        }
        
        pollingTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            await fetchChatRoomDataIfNeeded()
            
            while !Task.isCancelled {
                guard let chatRoomId else {
                    continue
                }
                
                await fetchChatMessages(chatRoomId: chatRoomId)
                
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }
            }
        }
    }
    
    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func fetchChatMessages(chatRoomId: Int) async {
        do {
            let messages = try await fetchChatMessagesUseCase.execute(
                recruitmentId: recruitmentId,
                chatRoomId: chatRoomId
            )
            outputSubject.send(.updateMessages(messages))
        } catch is CancellationError {
            return
        } catch {
            outputSubject.send(.showToast(errorMessage(from: error)))
        }
    }
}

extension RecruitChatViewModel {
    private func postMessage(text: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let request = RecruitChatPostRequest(content: text, isImage: false)
                try await postMessage(request: request)
            } catch {
                outputSubject.send(.showToast(errorMessage(from: error)))
            }
        }
    }
    
    private func postMessage(image: Data) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let imageUrl = try await uploadImage(image)
                let request = RecruitChatPostRequest(content: imageUrl, isImage: true)
                try await postMessage(request: request)
            } catch {
                outputSubject.send(.showToast(errorMessage(from: error)))
            }
        }
    }
    
    private func uploadImage(_ data: Data) async throws -> String {
        do {
            let response = try await uploadFileUseCase.execute(files: [data], domain: .recruit).firstValue()
            guard let imageUrl = response.fileUrls.first else {
                throw ErrorResponse.imageUploadError
            }
            return imageUrl
        } catch {
            throw error
        }
    }
    
    private func postMessage(request: RecruitChatPostRequest) async throws {
        guard let chatRoomId else {
            return
        }
        
        try await postChatMessageUseCase.execute(
            recruitmentId: recruitmentId,
            chatRoomId: chatRoomId,
            request: request
        )
    }
}

extension RecruitChatViewModel {
    private func errorMessage(from error: Error) -> String {
        (error as? ErrorResponse)?.message ?? error.localizedDescription
    }
}
