//
//  ActionBindableView.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import SwiftUI

@MainActor
protocol ActionBindableView: View {
    associatedtype Action
    var sendAction: ((Action) -> Void) { get set }
}
