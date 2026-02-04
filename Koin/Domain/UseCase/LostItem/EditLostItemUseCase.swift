//
//  EditLostItemUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/23/26.
//

import Foundation
import Combine

protocol UpdateLostItemUseCase {
    func execute(
        id: Int,
        lostItemData: LostItemData,
        imageUrls: [String],
        category: String,
        foundDate: String,
        foundPlace: String,
        content: String?
    ) -> AnyPublisher<LostItemData, ErrorResponse>
}

final class DefaultUpdateLostItemUseCase: UpdateLostItemUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(
        id: Int,
        lostItemData originalData: LostItemData,
        imageUrls updatedUrls: [String],
        category: String,
        foundDate: String,
        foundPlace: String,
        content: String?
    ) -> AnyPublisher<LostItemData, ErrorResponse> {
        
        let originalImageUrls = originalData.images.map { $0.imageUrl }
        let newImageUrls = updatedUrls.filter {
            !originalImageUrls.contains($0)
        }
        let deleteImageIds: [Int] = originalData.images.filter {
            !updatedUrls.contains($0.imageUrl)
        }.map {
            $0.id ?? 0
        }
        
        let requestModel = UpdateLostItemRequest(
            category: category,
            foundPlace: foundPlace,
            foundDate: foundDate,
            content: content,
            newImages: newImageUrls,
            deleteImageIds: deleteImageIds
        )
        
        return repository.updateLostItem(id: id, requestModel: requestModel)
    }
    
}
