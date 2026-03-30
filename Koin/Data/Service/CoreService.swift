//
//  CoreService.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Foundation
import Combine
import Alamofire

protocol CoreService {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, ErrorResponse>
    func fetchBanner() -> AnyPublisher<BannerDto, ErrorResponse>
    func uploadFiles(files: [Data], domain: String) -> AnyPublisher<FileUploadResponse, ErrorResponse>
}

final class DefaultCoreService: CoreService {
    
    private let networkService = NetworkService.shared
    
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: CoreAPI.checkVersion)
    }
    
    func fetchBanner() -> AnyPublisher<BannerDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CoreAPI.fetchBanner)
    }
    
    func uploadFiles(files: [Data], domain: String) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        return networkService.uploadFiles(api: CoreAPI.uploadFiles(files, domain))
    }
}
