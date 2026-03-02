//
//  NetworkService.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Foundation
import Alamofire
import Combine

final class NetworkService {
    
    static let shared = NetworkService()
    private let interceptor = Interceptor()
    private init() {
    }
    
    func request(api: URLRequestConvertible) -> AnyPublisher<Void, ErrorResponse> {
        return AF.request(api, interceptor: interceptor)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse.networkError
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return ()
                }
                if let data = response.data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        throw errorResponse.toDomain(withStatusCode: httpResponse.statusCode)
                    }
                    throw ErrorResponse.decodingError(httpResponse.statusCode)
                }
                throw ErrorResponse.emptyDataError(httpResponse.statusCode)
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func requestWithResponse<T: Decodable>(api: URLRequestConvertible) -> AnyPublisher<T, ErrorResponse> {
        return AF.request(api, interceptor: interceptor)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse.networkError
                }
                if 200..<300 ~= httpResponse.statusCode {
                    if let data = response.data {
                        if let decodedResponse = try? JSONDecoder().decode(T.self, from: data) {
                            return decodedResponse
                        }
                        throw ErrorResponse.decodingError(httpResponse.statusCode)
                    }
                    throw ErrorResponse.emptyDataError(httpResponse.statusCode)
                }
                if let data = response.data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        throw errorResponse.toDomain(withStatusCode: httpResponse.statusCode)
                    }
                    throw ErrorResponse.decodingError(httpResponse.statusCode)
                }
                throw ErrorResponse.emptyDataError(httpResponse.statusCode)
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func uploadFiles(api: ShopAPI) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        guard case ShopAPI.uploadFiles(let files) = api else {
            return Fail(error: ErrorResponse.invalidApi)
                .eraseToAnyPublisher()
        }
        
        return AF.upload(multipartFormData: api.asMultipartFormData(data: files),
                         to: api.baseURL + api.path,
                         method: api.method,
                         headers: Alamofire.HTTPHeaders(api.headers),
                         interceptor: interceptor)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse.networkError
                }
                if 200..<300 ~= httpResponse.statusCode {
                    if let data = response.data {
                        if let decodedResponse = try? JSONDecoder().decode(FileUploadResponse.self, from: data) {
                            return decodedResponse
                        }
                        throw ErrorResponse.decodingError(httpResponse.statusCode)
                    }
                    throw ErrorResponse.emptyDataError(httpResponse.statusCode)
                }
                if let data = response.data {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        throw errorResponse.toDomain(withStatusCode: httpResponse.statusCode)
                    }
                    throw ErrorResponse.decodingError(httpResponse.statusCode)
                }
                throw ErrorResponse.emptyDataError(httpResponse.statusCode)
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadFiles(api: URLRequest, fileName: String) -> AnyPublisher<URL?, ErrorResponse> {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return Fail(error: ErrorResponse.fileManagerFailedDirectory).eraseToAnyPublisher() }
        let fileUrl = documentsDirectory.appendingPathComponent(fileName)
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return AF.download(api, interceptor: interceptor, to: destination)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse.networkError
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return documentsDirectory
                }
                if let data = response.value {
                    if let errorRespose = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        throw errorRespose.toDomain(withStatusCode: httpResponse.statusCode)
                    }
                    throw ErrorResponse.decodingError(httpResponse.statusCode)
                }
                throw ErrorResponse.emptyDataError(httpResponse.statusCode)
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
        
    }
}

extension NetworkService {
    
    private func handleError(_ error: Error) -> ErrorResponse {
        if let errorResponse = error as? ErrorResponse {
            
            if let statusCode = errorResponse.statusCode,
               500..<600 ~= statusCode {
                NotificationCenter.default.post(name: NSNotification.Name("ServerError"), object: nil)
            }
            
            Log.make().error("\(errorResponse)")
            return errorResponse
        }
        
        Log.make().error("\(error)")
        return ErrorResponse.typeCastingError
    }
}
