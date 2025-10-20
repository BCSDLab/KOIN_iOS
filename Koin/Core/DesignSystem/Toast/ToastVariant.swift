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
    case overflow(lines: Int)   // 여러 줄 텍스트
}
