//
//  KeyChainWorker.swift
//  koin
//
//  Created by p on 3/18/24.
//

import Foundation

final class KeyChainWorker {
    
    enum TokenType: String {
        case access
        case refresh
        case fcm
    }
    static let shared = KeyChainWorker()
    
    private init() { }
    
    func create(key: TokenType, token: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess {
            print("Failed to save token, status code: \(status)")
        }
    }
    
    func read(key: TokenType) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else { return nil }
        } else {
            print("failed to loading, status code = \(status)")
            return nil
        }
    }
    
    func delete(key: TokenType) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        let status = SecItemDelete(query)
          if status == errSecSuccess {
              print("Item successfully deleted")
          } else if status == errSecItemNotFound {
              print("Item not found")
          } else {
              print("Error deleting the item, status code: \(status)")
          }
    }
    
}
