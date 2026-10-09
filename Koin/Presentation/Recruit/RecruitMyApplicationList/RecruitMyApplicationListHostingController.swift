//
//  RecruitMyApplicationListHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

final class RecruitMyApplicationListHostingController: UIHostingController<RecruitMyApplicationListView>, HostingControllerProtocol {

    // MARK: - Initializer
    override init(rootView: RecruitMyApplicationListView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        title = "내가 지원한 모집글"
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
        case .showFilterBottomSheet(let filterState, let onApplyTapped):
            showFilterBottomSheet(filterState, onApplyTapped)
        case .showToast(let message):
            showToastMessage(message: message)
        case .showRecruitData(let id):
            showRecruitData(id: id)
        case .showChat(let recruitmentId, let chatRoomId):
            showChat(recruitmentId: recruitmentId, chatRoomId: chatRoomId)
        case .showAllRecruitList:
            showAllRecruitList()
        }
    }
}

extension RecruitMyApplicationListHostingController {
    private func showRecruitData(id: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitDataViewModel(
            fetchRecruitDataUseCase: fetchUseCase,
            deleteRecruitDataUseCase: deleteUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            recruitId: id
        )
        let controller = RecruitDataHostingController(
            rootView: RecruitDataView(viewModel: viewModel),
            delegate: nil
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showChat(recruitmentId: Int, chatRoomId: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitChatViewModel(
            roomSource: .team(recruitmentId: recruitmentId, chatRoomId: chatRoomId),
            fetchTeamChatDataUseCase: DefaultFetchRecruitTeamChatDataUseCase(repository: repository),
            fetchDirectChatDataUseCase: DefaultFetchRecruitDirectChatDataUseCase(repository: repository),
            fetchChatMessagesUseCase: DefaultFetchRecruitChatMessagesUseCase(repository: repository),
            postChatMessageUseCase: DefaultPostRecruitChatMessageUseCase(repository: repository),
            uploadFileUseCase: DefaultUploadFileUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        )
        navigationController?.pushViewController(RecruitChatViewController(viewModel: viewModel), animated: true)
    }

    private func showAllRecruitList() {
        guard let navigationController,
              let recruitListController = navigationController.viewControllers.first(where: { $0 is RecruitListHostingController }) else {
            return
        }
        navigationController.popToViewController(recruitListController, animated: true)
    }
}

extension RecruitMyApplicationListHostingController {
    private func showFilterBottomSheet(
        _ filterState: RecruitMyApplicationFilter,
        _ onApplyTapped: @escaping ([FilterGroupModel]) -> Void
    ) {
        let filterBottomSheetView = FilterBottomSheetView(
            groupModels: filterState.toGroupModels(),
            onApplyTapped: onApplyTapped
        )
        let bottomSheetViewController = BottomSheetViewControllerB(contentView: filterBottomSheetView)
        filterBottomSheetView.delegate = bottomSheetViewController
        present(bottomSheetViewController, animated: true)
    }
}
