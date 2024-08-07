//
//  LandRepository.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

protocol LandRepository {
    func fetchLandList() -> AnyPublisher<LandDTO, Error>
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDTO, Error>
}
