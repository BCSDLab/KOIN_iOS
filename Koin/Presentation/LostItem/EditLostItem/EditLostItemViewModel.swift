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
        case editButtonTapped(([String], String, String, String, String?))
    }
    
    // MARK: - Output
    enum Output {
        case showToast(String)
        case addImageUrl(String)
        case updateData(LostItemData)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private(set) var lostItemData: LostItemData
    
    private let uploadFileUseCase: UploadFileUseCase = DefaultUploadFileUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService()))
    private let updateLostItemUseCase: UpdateLostItemUseCase
    

    // MARK: - Initialization
    init(updateLostItemUseCase: UpdateLostItemUseCase,
         lostItemData: LostItemData
    ) {
        self.updateLostItemUseCase = updateLostItemUseCase
        self.lostItemData = lostItemData
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .uploadFile(files):
                self.uploadFiles(files: files)
            case let .editButtonTapped((imageUrls, category, foundDate, foundPlace, content)):
                self.editButtonTapped(imageUrls, category, foundDate, foundPlace, content)
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
    
    private func editButtonTapped(
        _ imageUrls: [String],
        _ category: String,
        _ foundDate: String,
        _ foundPlace: String,
        _ content: String?
    ) {
        
        updateLostItemUseCase.execute(
            id: lostItemData.id,
            lostItemData: lostItemData,
            imageUrls: imageUrls,
            category: category,
            foundDate: foundDate,
            foundPlace: foundPlace,
            content: content
        ).sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print(failure)
                }
            },
            receiveValue: { [weak self] lostItemData in
                self?.outputSubject.send(.updateData(lostItemData))
            }
        ).store(in: &subscriptions)
    }
}
