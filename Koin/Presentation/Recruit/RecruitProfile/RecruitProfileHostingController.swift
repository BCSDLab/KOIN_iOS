//
//  RecruitProfileHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

final class RecruitProfileHostingController: UIHostingController<RecruitProfileView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: RecruitProfileView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "팀원 모집 프로필"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }

    // MARK: - Execute
    func execute(action: RecruitProfileView.Action) {
        switch action {
        case .showProfilePost:
            navigateToProfilePost()
        case .showProfileModify(let profile):
            navigateToProfileModify(profile: profile)
        case .showMyPosts:
            navigateToMyPosts()
        case .showMyApplications:
            navigateToMyApplications()
        case let .showToast(message):
            showToastMessage(message: message)
        }
    }
}

extension RecruitProfileHostingController {
    private func navigateToProfilePost() {
        // TODO: navigate
    }
    
    private func navigateToProfileModify(profile: RecruitProfile) {
        // TODO: navigate
    }
    
    private func navigateToMyPosts() {
        // TODO: navigate
    }
    
    private func navigateToMyApplications() {
        // TODO: navigate
    }
}
