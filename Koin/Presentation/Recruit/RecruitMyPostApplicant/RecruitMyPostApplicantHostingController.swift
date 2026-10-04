//
//  RecruitMyPostApplicantHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

final class RecruitMyPostApplicantHostingController: UIHostingController<RecruitMyPostApplicantView>, HostingControllerProtocol {

    // MARK: - Initializer
    override init(rootView: RecruitMyPostApplicantView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        title = "지원자 상세"
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
        case .showDecisionModal(let decision):
            showDecisionModal(decision)
        case .showDirectChat(let recruitmentId, let applicationId):
            showDirectChat(recruitmentId: recruitmentId, applicationId: applicationId)
        case .showToast(let message):
            showToastMessage(message: message, bottomInset: 80)
        }
    }
}

extension RecruitMyPostApplicantHostingController {
    private func showDecisionModal(_ decision: RecruitApplicantDecision) {
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "해당 지원자를 \(decision.rawValue)하시겠어요?",
                subTitleText: "\(decision.rawValue) 후에는 '\(decision.rawValue)' 상태로 변경되며\n지원자에게 \(decision.rawValue) 알림이 전송됩니다.",
            ),
            button: .buttons(
                leftButtonTitle: "취소하기",
                rightButtonTitle: "\(decision.rawValue)하기",
                rightButtonAction: { [weak self] in
                    self?.rootView.decide(decision)
                }
            )
        ))
        present(modalViewController, animated: true)
    }

    private func showDirectChat(recruitmentId: Int, applicationId: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitChatViewModel(
            roomSource: .direct(recruitmentId: recruitmentId, applicationId: applicationId),
            fetchTeamChatDataUseCase: DefaultFetchRecruitTeamChatDataUseCase(repository: repository),
            fetchDirectChatDataUseCase: DefaultFetchRecruitDirectChatDataUseCase(repository: repository),
            fetchChatMessagesUseCase: DefaultFetchRecruitChatMessagesUseCase(repository: repository),
            postChatMessageUseCase: DefaultPostRecruitChatMessageUseCase(repository: repository),
            uploadFileUseCase: DefaultUploadFileUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        )
        navigationController?.pushViewController(RecruitChatViewController(viewModel: viewModel), animated: true)
    }
}
