//
//  CommunityRequest.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

class CommunityRequest {
    let request: URLRequest?
    let error: KoinCommunityError?
    
    init(request: URLRequest?, error: KoinCommunityError?) {
        self.request = request
        self.error = error
    }
    
    func isError() -> Bool {
        return (error != nil) ? true : false
    }
    
    func getRequest() -> URLRequest {
        return request!
    }
    
    func getError() -> KoinCommunityError {
        return error!
    }
}
