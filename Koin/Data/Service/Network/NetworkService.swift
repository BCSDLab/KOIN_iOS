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
    
    private let interceptor = Interceptor()
    
    func request(api: URLRequestConvertible) -> AnyPublisher<Void, Error> {
        return AF.request(api, interceptor: interceptor)
            .validate()
            .publishData()
            .value()
            .map { _ in }
            .mapError { error -> Error in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func request(api: URLRequestConvertible) -> AnyPublisher<Void, ErrorResponse> {
        return AF.request(api, interceptor: interceptor)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw URLError(.badServerResponse)
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return ()
                } else if httpResponse.statusCode == 401 {
                    throw ErrorResponse(code: "401", message: "")
                } else {
                    if let data = response.data {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        throw errorResponse
                    } else {
                        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode))
                        throw afError
                    }
                }
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func requestWithResponse<T: Decodable>(api: URLRequestConvertible) -> AnyPublisher<T, Error> {
        return AF.request(api, interceptor: interceptor)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { error -> Error in
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
                    throw URLError(.badServerResponse)
                }
                if 200..<300 ~= httpResponse.statusCode {
                    guard let data = response.data else {
                        throw ErrorResponse(code: "", message: "알 수 없는 에러")
                    }
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } else if httpResponse.statusCode == 401 {
                    throw ErrorResponse(code: "401", message: "")
                } else {
                    if let data = response.data {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        throw errorResponse
                    } else {
                        let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode))
                        throw afError
                    }
                }
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func uploadFiles(api: ShopAPI) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        guard case ShopAPI.uploadFiles(let files) = api else {
            return Fail(error: ErrorResponse(code: "invalid_api", message: "Invalid API case for file upload"))
                .eraseToAnyPublisher()
        }
        
        return AF.upload(multipartFormData: api.asMultipartFormData(data: files),
                         to: api.baseURL + api.path,
                         method: api.method,
                         headers: Alamofire.HTTPHeaders(api.headers),
                         interceptor: interceptor)
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse(code: "", message: "서버 응답 오류")
                }
                if 200..<300 ~= httpResponse.statusCode,
                   let data = response.data,
                   let decodedResponse = try? JSONDecoder().decode(FileUploadResponse.self, from: data) {
                    return decodedResponse
                }
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw errorResponse
                } else {
                    throw ErrorResponse(code: "", message: "ErrorResponse 디코딩 실패")
                }
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadFiles(api: URLRequest, fileName: String) -> AnyPublisher<URL?, ErrorResponse> {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return Fail(error: ErrorResponse(code: "001", message: "파일 저장 위치 찾기 실패")).eraseToAnyPublisher() }
        let fileUrl = documentsDirectory.appendingPathComponent(fileName)
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return AF.download(api, interceptor: interceptor, to: destination)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw URLError(.badServerResponse)
                }
                
                if 200..<300 ~= httpResponse.statusCode {
                    print("File is downloaded")
                    return documentsDirectory
                } else {
                    if let error = response.error {
                        print("Download Failed - \(error)")
                    } else {
                        throw ErrorResponse(code: "\(httpResponse.statusCode)", message: "알 수 없는 에러")
                    }
                }
                return nil
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
            if let code = Int(errorResponse.code),
               500..<600 ~= code {
                NotificationCenter.default.post(name: NSNotification.Name("ServerError"), object: nil)
            }
            return errorResponse
        }
        return ErrorResponse(code: "", message: "알 수 없는 에러")
    }
    
    private func handleError(_ error: AFError) -> Error {
        if let code = error.responseCode,
           500..<600 ~= code {
            NotificationCenter.default.post(name: NSNotification.Name("ServerError"), object: nil)
        }
        return error as Error
    }
}
