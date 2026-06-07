//
//  String+byCharWrapping.swift
//  koin
//
//  Created by 홍기정 on 6/7/26.
//

import Foundation

/// 문자열 글자 사이사이에 Zero Width Space를 삽입합니다.
/// SwiftUI Text가 lineBreakMode(.byCharWrapping) 처럼 동작하도록 합니다.
extension String {
    var byCharWrapping: String {
        self.map { String($0) }.joined(separator: "\u{200B}")
    }
}
