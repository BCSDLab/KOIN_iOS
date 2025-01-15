//
//  LostArticleReportViewModel.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine
import Foundation

final class LostArticleReportViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case uploadFile([Data])
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String)
        case addImageUrl(String, Int)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    var selectedIndex = 0
    private lazy var uploadFileUseCase: UploadFileUseCase = DefaultUploadFileUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService()))
    
    
    // MARK: - Initialization
    
    init() {
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .uploadFile(files):
                self?.uploadFiles(files: files)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension LostArticleReportViewModel {
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
