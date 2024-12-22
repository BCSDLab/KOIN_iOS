//
//  MockNetworkService.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Alamofire
import Combine

class MockNetworkService {
    func request<T: Decodable>(api: URLRequest) -> AnyPublisher<T, Error> {
        
        return AF.request(api)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw URLError(.badServerResponse)
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    if let data = response.data {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        throw errorResponse
                    } else {
                        throw ErrorResponse(code: "", message: "알 수 없는 에러")
                    }
                }
                
                guard let data = response.data else {
                    throw ErrorResponse(code: "", message: "응답이 없음")
                }
                
                return try JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error in
                
                return error
            }
            .eraseToAnyPublisher()
    }
}
