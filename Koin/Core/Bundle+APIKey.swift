//
//  Bundle+APIKey.swift
//  koin
//
//  Created by 김나훈 on 8/1/24.
//

import Foundation

extension Bundle {
    
    var baseUrl: String {
        return object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
    }
    
    var kakaoApiKey: String {
        return object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String ?? ""
    }
}
