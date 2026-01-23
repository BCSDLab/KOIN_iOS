//
//  LostItemRepository.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine

protocol LostItemRepository {
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemList, Error>
}
