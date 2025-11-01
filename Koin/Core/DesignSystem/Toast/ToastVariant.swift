//
//  ToastVariant.swift
//  koin
//
//  Created by 이은지 on 10/19/25.
//

import Foundation

enum ToastVariant {
    case standard               // 텍스트만
    case action(title: String)  // 텍스트 + 버튼
    
    var hasButton: Bool {
        switch self {
        case .action:
            return true
        case .standard:
            return false
        }
    }
    
    var buttonTitle: String? {
        switch self {
        case .action(let title):
            return title
        case .standard:
            return nil
        }
    }
}
