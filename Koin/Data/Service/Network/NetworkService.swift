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
    
    func request(api: URLRequestConvertible) -> AnyPublisher<Void, ErrorResponse> {
        return AF.request(api, interceptor: interceptor)
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse(code: "NETWORK_ERROR", message: "서버 응답 오류")
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return ()
                }
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw errorResponse.statusCode(httpResponse.statusCode)
                }
                throw ErrorResponse(statusCode: httpResponse.statusCode, code: "", message: "ErrorResponse 디코딩 실패")
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func requestWithResponse<T: Decodable>(api: URLRequestConvertible) -> AnyPublisher<T, ErrorResponse> {
        return AF.request(api, interceptor: interceptor)
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse(code: "NETWORK_ERROR", message: "서버 응답 오류")
                }
                if 200..<300 ~= httpResponse.statusCode {
                    if let data = response.data,
                       let decodedResponse = try? JSONDecoder().decode(T.self, from: data) {
                        return decodedResponse
                    }
                    throw ErrorResponse(statusCode: httpResponse.statusCode, code: "PARSING_ERROR", message: "응답 본문 디코딩 실패")
                }
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw errorResponse.statusCode(httpResponse.statusCode)
                }
                throw ErrorResponse(statusCode: httpResponse.statusCode, code: "PARSING_ERROR", message: "ErrorResponse 디코딩 실패")
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
                    throw ErrorResponse(code: "NETWORK_ERROR", message: "서버 응답 오류")
                }
                if 200..<300 ~= httpResponse.statusCode {
                    if let data = response.data,
                       let decodedResponse = try? JSONDecoder().decode(FileUploadResponse.self, from: data) {
                        return decodedResponse
                    }
                    throw ErrorResponse(statusCode: httpResponse.statusCode, code: "PARSING_ERROR", message: "응답 본문 디코딩 실패")
                }
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw errorResponse.statusCode(httpResponse.statusCode)
                }
                throw ErrorResponse(statusCode: httpResponse.statusCode, code: "PARSING_ERROR", message: "ErrorResponse 디코딩 실패")
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadFiles(api: URLRequest, fileName: String) -> AnyPublisher<URL?, ErrorResponse> {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return Fail(error: ErrorResponse(code: "FILEMANAGER_FAILED", message: "파일 저장 위치 찾기 실패")).eraseToAnyPublisher() }
        let fileUrl = documentsDirectory.appendingPathComponent(fileName)
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return AF.download(api, interceptor: interceptor, to: destination)
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw ErrorResponse(code: "NETWORK_ERROR", message: "서버 응답 오류")
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return documentsDirectory
                }
                if let data = response.value,
                   let errorRespose = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw errorRespose.statusCode(httpResponse.statusCode)
                }
                throw ErrorResponse(statusCode: httpResponse.statusCode, code: "DOWNLOAD_FAILED", message: "다운로드 실패")
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
            return errorResponse
        }
        
        return ErrorResponse(code: "", message: "알 수 없는 에러")
    }
}
