//
//  MockFetchDeptListUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Combine

final class MockFetchDeptListUseCase: FetchDeptListUseCase {
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        Just([
            "건축공학부",
            "고용서비스정책학과",
            "기계공학부",
            "메카트로닉스공학부",
            "산업경영학부",
            "에너지신소재화학공학부",
            "전기전자통신공학부",
            "컴퓨터공학부"
        ])
        .setFailureType(to: ErrorResponse.self)
        .eraseToAnyPublisher()
    }
}
