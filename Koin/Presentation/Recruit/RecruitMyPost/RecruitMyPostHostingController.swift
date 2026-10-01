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
        case .showDirectChat(let recruitmentId, let applicationId):
            showDirectChat(recruitmentId: recruitmentId, applicationId: applicationId)
        case .showChat(let recruitmentId, let chatRoomId):
            showChat(recruitmentId: recruitmentId, chatRoomId: chatRoomId)
        }
    }
}

extension RecruitMyPostHostingController {
    private func showApplicant(recruitmentId: Int, applicationId: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitApplicantUseCase(repository: repository)
        let decideUseCase = DefaultDecideRecruitApplicantUseCase(repository: repository)
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

    private func showDirectChat(recruitmentId: Int, applicationId: Int) {
        pushRecruitChat(roomSource: .direct(recruitmentId: recruitmentId, applicationId: applicationId))
    }

    private func showChat(recruitmentId: Int, chatRoomId: Int) {
        pushRecruitChat(roomSource: .team(recruitmentId: recruitmentId, chatRoomId: chatRoomId))
    }

    private func pushRecruitChat(roomSource: RecruitChatViewModel.RoomSource) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitChatViewModel(
            roomSource: roomSource,
            fetchTeamChatDataUseCase: DefaultFetchRecruitTeamChatDataUseCase(repository: repository),
            fetchDirectChatDataUseCase: DefaultFetchRecruitDirectChatDataUseCase(repository: repository),
            fetchChatMessagesUseCase: DefaultFetchRecruitChatMessagesUseCase(repository: repository),
            postChatMessageUseCase: DefaultPostRecruitChatMessageUseCase(repository: repository),
            uploadFileUseCase: DefaultUploadFileUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        )
        navigationController?.pushViewController(RecruitChatViewController(viewModel: viewModel), animated: true)
    }
}
