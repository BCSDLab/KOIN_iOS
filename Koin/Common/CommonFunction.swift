//
//  CommonFunction.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/17.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import Combine

func checkRegex(target: String, pattern: String) -> Bool {
    
    do {
        print(target)
        print(pattern)
        let range = NSRange(location: 0, length: target.utf16.count)
        let regex = try NSRegularExpression(pattern: pattern)
        let filtered = regex.matches(in: target, options: [], range: range)
        
        if (filtered.isEmpty) {
            return false
        } else {
            return true
        }
    } catch(let error) {
        print(error)
        return false
    }
    return false
}
