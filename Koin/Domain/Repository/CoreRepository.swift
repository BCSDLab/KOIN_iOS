//
//  CoreRepository.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Foundation
import Combine

protocol CoreRepository {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, ErrorResponse>
    func fetBanner() -> AnyPublisher<BannerDto, ErrorResponse>
    func uploadFiles(files: [Data], domain: String) -> AnyPublisher<FileUploadResponse, ErrorResponse>
}
