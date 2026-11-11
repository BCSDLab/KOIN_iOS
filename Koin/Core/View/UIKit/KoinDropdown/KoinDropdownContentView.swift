//
//  KoinDropdownContentView.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit
import Combine

@MainActor
protocol KoinDropdownContentView: AnyObject {
    var dismissTappedPublisher: AnyPublisher<Void, Never> { get }
    var height: CGFloat { get }
}
