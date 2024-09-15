//
//  UploadFileUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import Foundation

protocol UploadFileUseCase {
    func execute(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
}

final class DefaultUploadFileUseCase: UploadFileUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        return shopRepository.uploadFiles(files: files)
    }
}
