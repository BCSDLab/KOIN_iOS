//
//  MockNetworkService.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Foundation
import Alamofire
import Combine

class MockNetworkService {
    func request<T: Decodable>(api: URLRequest) -> AnyPublisher<T, ErrorResponse> {
        
        return AF.request(api)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse.networkError
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    if let data = response.data {
                        if let errorResponse = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                            throw errorResponse.toDomain(withStatusCode: httpResponse.statusCode)
                        }
                        throw ErrorResponse.decodingError(httpResponse.statusCode)
                    } else {
                        throw ErrorResponse.emptyDataError(httpResponse.statusCode)
                    }
                }
                
                guard let data = response.data else {
                    throw ErrorResponse.emptyDataError(httpResponse.statusCode)
                }
                
                if let response = try? JSONDecoder().decode(T.self, from: data) {
                    return response
                } else {
                    throw ErrorResponse.decodingError(httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let errorResponse = error as? ErrorResponse {
                    return errorResponse
                }
                return ErrorResponse.typeCastingError
            }
            .eraseToAnyPublisher()
    }
}
