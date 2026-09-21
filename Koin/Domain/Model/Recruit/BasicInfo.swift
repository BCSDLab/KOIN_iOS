//
//  BasicInfo.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct BasicInfo {
    var nickname: String? = nil
    var department: String? = nil
    var studentNumber: String? = nil
}

extension BasicInfo {
    var isValid: Bool {
        guard let nickname,
              !nickname.isEmpty,
              let department,
              !department.isEmpty,
              let studentNumber,
              !studentNumber.isEmpty else {
            return false
        }
        return true
    }
}
