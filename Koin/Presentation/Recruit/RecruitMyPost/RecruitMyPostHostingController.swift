//
//  RecruitMyPostHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

final class RecruitMyPostHostingController: UIHostingController<RecruitMyPostView>, HostingControllerProtocol {

    // MARK: - Initializer
    override init(rootView: RecruitMyPostView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        title = "지원자 관리"
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }

    // MARK: - Public
    func execute(action: RootView.Action) {
        switch action {
        case .showToast(let message):
            showToastMessage(message: message)
        case .showApplicant(let recruitmentId, let applicationId):
            showApplicant(
                recruitmentId: recruitmentId,
                applicationId: applicationId
            )
        case .showDirectChat:
            showDirectChat()
        }
    }
}

extension RecruitMyPostHostingController {
    private func showApplicant(recruitmentId: Int, applicationId: Int) {
        let repository = MockRecruitRepository()
        let fetchUseCase = DefaultFetchRecruitMyPostApplicationUseCase(repository: repository)
        let decideUseCase = DefaultDecideRecruitMyPostApplicationUseCase(repository: repository)
        let viewModel = RecruitMyPostApplicantViewModel(
            recruitmentId: recruitmentId,
            applicationId: applicationId,
            fetchUseCase: fetchUseCase,
            decideUseCase: decideUseCase
        )
        let controller = RecruitMyPostApplicantHostingController(
            rootView: RecruitMyPostApplicantView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showDirectChat() {
        // TODO: 지원자와의 1:1 채팅 화면 연결
    }
}
