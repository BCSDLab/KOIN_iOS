//
//  SwiftUIViewModelProtocol.swift
//  Koin
//
//  Created by 홍기정 on 6/2/26.
//

import Foundation

@MainActor
protocol SwiftUIViewModelProtocol: AnyObject {
    associatedtype Input

    func execute(_ input: Input)
}
