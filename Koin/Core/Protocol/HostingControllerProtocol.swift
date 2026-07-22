//
//  HostingControllerProtocol.swift
//  Koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

@MainActor
protocol HostingControllerProtocol: AnyObject {
    associatedtype RootView: ActionBindableView

    var rootView: RootView { get set }
    func execute(action: RootView.Action)
}

extension HostingControllerProtocol {
    func bindAction(to rootView: RootView) {
        var boundRootView = rootView
        boundRootView.sendAction = { [weak self] action in
            self?.execute(action: action)
        }
        self.rootView = boundRootView
    }
}
