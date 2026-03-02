//
//  KeychainWorker.swift
//  koin
//
//  Created by p on 3/18/24.
//

import Foundation

final class KeychainWorker {
    
    enum TokenType: String {
        case access
        case refresh
        case fcm
        case accessHistoryId
        case variableName
        case shareVariableName
    }
    static let shared = KeychainWorker()
    
    private init() {}
    private var keychains: [String: String?] = [:]
    private let lock = NSLock()
    
    func create(key: TokenType, token: String) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let deleteQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key)
        ]
        SecItemDelete(deleteQuery)
        keychains.removeValue(forKey: keyType(key: key))
        
        let addQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key),
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        let status = SecItemAdd(addQuery, nil)
        
        if status == errSecSuccess {
//            print(key, "저장성공 :", token)
            keychains.updateValue(token, forKey: keyType(key: key))
        } else {
            print(key, "저장실패 :", SecCopyErrorMessageString(status, nil) ?? "")
        }
    }
    
    func read(key: TokenType) -> String? {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if let token: String? = keychains[keyType(key: key)] {
//            print("캐싱된", key, "읽기성공 :", token ?? "nil")
            return token
        }
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key),
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess,
           let retrievedData: Data = dataTypeRef as? Data,
           let value = String(data: retrievedData, encoding: String.Encoding.utf8) {
            keychains.updateValue(value, forKey: keyType(key: key))
//            print("키체인에서", key, "읽기성공 :", value)
            return value
        } else if status == errSecItemNotFound {
//            print("키체인에서", key, "읽기성공 : nil")
            keychains.updateValue(nil, forKey: keyType(key: key))
            return nil
        } else {
            print(key, "읽기 실패 :", SecCopyErrorMessageString(status, nil) ?? "")
            return nil
        }
    }
    
    func delete(key: TokenType) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        keychains.removeValue(forKey: keyType(key: key))
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key)
        ]
        let status = SecItemDelete(query)
        if status == errSecSuccess {
//            print(key, "삭제성공 :")
            return
        } else {
            print(key, "삭제실패 :", SecCopyErrorMessageString(status, nil) ?? "")
        }
    }
}

extension KeychainWorker {
    
    private func keyType(key: TokenType) -> String {
        let keyType: String
        
        if Bundle.main.isStage {
            keyType = "stage\(key.rawValue)"
        } else {
            keyType = key.rawValue
        }
        
        return keyType
    }
}
