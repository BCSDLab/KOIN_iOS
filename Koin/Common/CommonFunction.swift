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

extension String {
    func getArrayAfterRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                    range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

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
