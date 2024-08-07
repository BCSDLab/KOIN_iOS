//
//  Router.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Alamofire

public protocol Router {
    var baseURL: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: Any? { get }
    var encoding: ParameterEncoding? { get }
}

extension Router {
    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.method = method
        request.headers = Alamofire.HTTPHeaders(headers)
        
        if let parameters = parameters {
            if let parameters = parameters as? [String: Any], let encoding = encoding {
                request = try encoding.encode(request, with: parameters)
            } else if let parameters = parameters as? Data {
                request.httpBody = parameters
            }
        }
        
        return request
    }
}

extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return jsonObject as? [String: Any]
    }
}
