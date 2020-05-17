//
//  UserRequest.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

class UserRequest {
    let request: URLRequest?
    let error: UserError?
    
    init(request: URLRequest?, error: UserError?) {
        self.request = request
        self.error = error
    }
    
    func isError() -> Bool {
        return (error != nil) ? true : false
    }
    
    func getRequest() -> URLRequest {
        return request!
    }
    
    func getError() -> Error {
        return error!
    }
}

struct UserResponse: Codable, Hashable {
    let success: Bool
}
