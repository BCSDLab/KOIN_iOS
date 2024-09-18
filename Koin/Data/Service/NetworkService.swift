//
//  NetworkService.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//


import Alamofire
import Combine

class NetworkService {
    func request(api: URLRequestConvertible) -> AnyPublisher<Void, ErrorResponse> {
        return AF.request(api)
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
    
    func requestWithResponse<T: Decodable>(api: URLRequestConvertible) -> AnyPublisher<T, ErrorResponse> {
        return AF.request(api)
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
    
    func handleError(_ error: Error) -> ErrorResponse {
        if let errorResponse = error as? ErrorResponse {
            return errorResponse
        }
        return ErrorResponse(code: "", message: "알 수 없는 에러")
    }
    
    func refreshToken() -> AnyPublisher<Void, ErrorResponse> {
        return requestWithResponse(api: UserAPI.refreshToken(RefreshTokenRequest(refreshToken: KeyChainWorker.shared.read(key: .refresh) ?? "")))
            .map { (tokenDTO: TokenDTO) -> Void in
                KeyChainWorker.shared.create(key: .access, token: tokenDTO.token)
                KeyChainWorker.shared.create(key: .refresh, token: tokenDTO.refreshToken)
                return ()
            }
            .catch { error -> AnyPublisher<Void, ErrorResponse> in
                KeyChainWorker.shared.delete(key: .access)
                KeyChainWorker.shared.delete(key: .refresh)
                return Fail(error: ErrorResponse(code: "401", message: "인증정보가 만료되었습니다. 다시 로그인해주세요.")).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func uploadFiles(api: ShopAPI) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        guard case ShopAPI.uploadFiles(let files) = api else {
            return Fail(error: ErrorResponse(code: "invalid_api", message: "Invalid API case for file upload"))
                .eraseToAnyPublisher()
        }
        
        return Future<FileUploadResponse, ErrorResponse> { promise in
            api.asMultipartRequest(data: files, withName: "files", fileName: "file", mimeType: "image/png")
                .responseDecodable(of: FileUploadResponse.self) { response in
                    switch response.result {
                    case .success(let fileUploadResponse):
                        promise(.success(fileUploadResponse))
                    case .failure:
                        if let data = response.data {
                            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                            promise(.failure(errorResponse ?? ErrorResponse(code: "unknown", message: "An unknown error occurred")))
                        } else {
                            promise(.failure(ErrorResponse(code: "unknown", message: "An unknown error occurred")))
                        }
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadFiles(api: URLRequest, fileName: String) -> AnyPublisher<Void, ErrorResponse> {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return Fail(error: ErrorResponse(code: "001", message: "파일 저장 위치 찾기 실패")).eraseToAnyPublisher() }
        print(documentsDirectory)
        let destination: DownloadRequest.Destination = { _, _ in
            let fileUrl = documentsDirectory.appendingPathComponent(fileName)
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return AF.download(api, to: destination)
            .validate()
            .publishData()
            .tryMap { response in
                guard let httpResponse = response.response else {
                    throw URLError(.badServerResponse)
                }
                
                if 200..<300 ~= httpResponse.statusCode {
                    print("File is downloaded")
                    return
                } else {
                    if let error = response.error {
                        print("Download Failed - \(error)")
                    } else {
                        throw ErrorResponse(code: "\(httpResponse.statusCode)", message: "알 수 없는 에러")
                    }
                }
            }
            .mapError { error -> ErrorResponse in
                self.handleError(error)
            }
            .eraseToAnyPublisher()
        
    }
}
