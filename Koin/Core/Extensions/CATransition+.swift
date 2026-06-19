//
//  CATransition+.swift
//  koin
//
//  Created by 홍기정 on 6/19/26.
//

import QuartzCore

extension CATransition {
    
    static var fade: CATransition {
        return CATransition().then {
            $0.type = .fade
            $0.duration = 0.2
        }
    }
}
