//
//  EncodingWorker.swift
//  koin
//
//  Created by 김나훈 on 3/21/24.
//

import CryptoKit
import Foundation

struct EncodingWorker {
    
    func sha256(text: String) -> String {
        let inputData = Data(text.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
