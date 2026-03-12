//
//  UploadFileUseCase.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine
import Foundation

protocol UploadFileUseCase {
    func execute(files: [Data], domain: UploadDomain) -> AnyPublisher<FileUploadResponse, ErrorResponse>
}

final class DefaultUploadFileUseCase: UploadFileUseCase {
    
    private let coreRepository: CoreRepository
    
    init(coreRepository: CoreRepository) {
        self.coreRepository = coreRepository
    }
    
    func execute(files: [Data], domain: UploadDomain) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        return coreRepository.uploadFiles(files: files, domain: domain.rawValue)
    }
}
