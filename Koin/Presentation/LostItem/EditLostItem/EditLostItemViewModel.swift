//
//  EditLostItemViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import Combine
import Foundation

final class EditLostItemViewModel: ViewModelProtocol {
    
    // MARK: - Input
    enum Input {
        case uploadFile([Data])
    }
    
    // MARK: - Output
    enum Output {
        case showToast(String)
        case addImageUrl(String)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private(set) var lostItemData: LostItemData
    
    private let uploadFileUseCase: UploadFileUseCase = DefaultUploadFileUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService()))
    

    // MARK: - Initialization
    init(lostItemData: LostItemData) {
        self.lostItemData = lostItemData
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .uploadFile(files):
                self.uploadFiles(files: files)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension EditLostItemViewModel {
    
    private func uploadFiles(files: [Data]) {
        uploadFileUseCase.execute(files: files).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] response in
            response.fileUrls.forEach {
                self?.outputSubject.send(.addImageUrl($0))
            }
        }.store(in: &subscriptions)
        
    }
}
