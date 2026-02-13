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
    private var keychains: [TokenType: String?] = [:]
    private let lock = NSLock()
    
    func create(key: TokenType, token: String) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key),
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query)
        keychains.removeValue(forKey: key)
        
        let status = SecItemAdd(query, nil)
        if status == errSecSuccess {
            keychains.updateValue(token, forKey: key)
        } else {
            print("Failed to save \(key) token,", SecCopyErrorMessageString(status, nil) ?? "")
        }
    }
    
    func read(key: TokenType) -> String? {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if let token: String? = keychains[key] {
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
            keychains.updateValue(value, forKey: key)
            return value
        } else if status == errSecItemNotFound {
            keychains.updateValue(nil, forKey: key)
            return nil
        } else {
            print("Failed to load \(key) token,", SecCopyErrorMessageString(status, nil) ?? "")
            return nil
        }
    }
    
    func delete(key: TokenType) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        keychains.removeValue(forKey: key)
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyType(key: key)
        ]
        let status = SecItemDelete(query)
        if status == errSecSuccess {
            return
        } else if status == errSecItemNotFound {
            print("\(key) token not found")
        } else {
            print("Error deleting \(key) token", SecCopyErrorMessageString(status, nil) ?? "")
        }
    }
}

extension KeychainWorker {
    
    private func keyType(key: TokenType) -> String {
        let keyType: String
        if key == .accessHistoryId {
            if Bundle.main.isStage {
                keyType = "stage\(key.rawValue)"
            } else {
                keyType = "production\(key.rawValue)"
            }
        } else {
            keyType = key.rawValue
        }
        return keyType
    }
}
