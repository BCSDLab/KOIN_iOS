//
//  RecruitMyPostHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

final class RecruitMyPostHostingController: UIHostingController<RecruitMyPostView>, HostingControllerProtocol {
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
        title = "지원자 관리"
    }

    // MARK: - Public
    func execute(action: RootView.Action) {
        switch action {
        case .showToast(let message):
            showToastMessage(message: message)
        }
    }
}
