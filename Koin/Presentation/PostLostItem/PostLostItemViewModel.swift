//
//  PostLostItemViewModel.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine
import Foundation

final class PostLostItemViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case uploadFile([Data])
        case postLostItem([PostLostItemRequest])
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String)
        case addImageUrl(String, Int)
        case popViewController(Int)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    var selectedIndex = 0
    private lazy var uploadFileUseCase: UploadFileUseCase = DefaultUploadFileUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService()))
    private lazy var postLostItemUseCase: PostLostItemUseCase = DefaultPostLostItemUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
    private let type: LostItemType
    
    // MARK: - Initialization
    
    init(type: LostItemType) {
        self.type = type
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .uploadFile(files):
                self?.uploadFiles(files: files)
            case let .postLostItem(request):
                self?.postLostItem(request: request)
            case let .logEvent(label, category, value):
                self?.logEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension PostLostItemViewModel {
    
    private func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
    
    private func postLostItem(request: [PostLostItemRequest]) {
        let updatedRequests = request.map { request in
              var updatedRequest = request
              updatedRequest.type = self.type 
              return updatedRequest
          }
          
          postLostItemUseCase.execute(request: updatedRequests)
              .sink { [weak self] completion in
                  if case let .failure(error) = completion {
                      self?.outputSubject.send(.showToast(error.message))
                  }
              } receiveValue: { [weak self] response in
                  self?.outputSubject.send(.showToast("게시글 작성이 완료되었습니다."))
                  self?.outputSubject.send(.popViewController(response.id))
              }.store(in: &subscriptions)
    }
    
    private func uploadFiles(files: [Data]) {
        uploadFileUseCase.execute(files: files).sink { [weak self] completion in
            if case let .failure(error) = completion {               
                self?.outputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.addImageUrl(response.fileUrls.first ?? "", self?.selectedIndex ?? 0))            
        }.store(in: &subscriptions)
        
    }
    
}
