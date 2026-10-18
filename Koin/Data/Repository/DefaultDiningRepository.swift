//
//  DefaultDiningRepository.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Combine
import Foundation

final class DefaultDiningRepository: DiningRepository {
    private let diningService: DiningService
    private let shareService: ShareService
    
    init(diningService: DiningService, shareService: ShareService) {
        self.diningService = diningService
        self.shareService = shareService
    }
    
    func fetchDiningList(date: Date) -> AnyPublisher<[DiningItem], ErrorResponse> {
        let requestModel = FetchDiningListRequest(date: date.formatDateToYYMMDD())
        return diningService.fetchDiningList(requestModel: requestModel)
            .map { diningList in
                diningList.compactMap { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCoopShopList() -> AnyPublisher<CoopShopData, ErrorResponse> {
        return diningService.fetchCoopShopList()
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
    func shareMenuList(shareModel: ShareDiningMenu) {
        shareService.shareMenuList(shareModel: shareModel)
    }
  
    func reportSoldout(diningId: Int, imageUrl: String) async throws -> Void {
        let request = ReportSoldoutRequestDto(imageUrl: imageUrl)
        try await diningService.reportSoldout(diningId: diningId, request: request)
    }
}
