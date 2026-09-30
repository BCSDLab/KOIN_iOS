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
        case .showDirectChat:
            showDirectChat()
        case .showToast(let message):
            showToastMessage(message: message, bottomInset: 80)
        }
    }
}

extension RecruitMyPostApplicantHostingController {
    private func showDecisionModal(_ decision: RecruitApplicationDecision) {
        let copy: (title: String, subtitle: String, action: String)
        switch decision {
        case .accepted:
            copy = (
                "해당 지원자를 승인하시겠어요?",
                "승인 후에는 ‘승인’ 상태로 변경되며\n지원자에게 승인 알림이 전송됩니다.",
                "승인하기"
            )
        case .denied:
            copy = (
                "해당 지원자를 거절하시겠어요?",
                "거절 후에는 ‘거절’ 상태로 변경되며\n지원자에게 거절 알림이 전송됩니다.",
                "거절하기"
            )
        }

        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: copy.title,
                mainTitleStyle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15
                ),
                subTitleText: copy.subtitle,
                subTitleStyle: .init(
                    textColor: .neutral500,
                    font: .pretendardRegular,
                    fontSize: 13
                )
            ),
            button: .buttons(
                leftButtonTitle: "취소하기",
                leftButtonStyle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15,
                    borderColor: .neutral400,
                    borderWidth: 1,
                    cornerRadius: 8
                ),
                rightButtonTitle: copy.action,
                rightButtonAction: { [weak self] in
                    self?.rootView.decide(decision)
                },
                rightButtonStyle: .init(
                    textColor: .neutral0,
                    font: .pretendardMedium,
                    fontSize: 15,
                    backgroundColor: .new500,
                    cornerRadius: 8
                )
            )
        ))
        present(modalViewController, animated: true)
    }

    private func showDirectChat() {
        // TODO: 지원자와의 1:1 채팅 화면 연결
    }
}
