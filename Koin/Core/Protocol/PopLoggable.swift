//
//  PopLoggable.swift
//  koin
//
//  Created by 홍기정 on 5/31/26.
//

import UIKit

protocol PopLoggable where Self: UIViewController {
    func sendPopLog(category: EventParameter.EventCategory)
}
