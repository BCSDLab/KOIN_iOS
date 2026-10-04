//
//  RecruitMyPostListHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

final class RecruitMyPostListHostingController: UIHostingController<RecruitMyPostListView>, HostingControllerProtocol {

    // MARK: - Initializer
    override init(rootView: RecruitMyPostListView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        title = "내가 작성한 모집글"
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
        case .showApplicants(let recruitId):
            showApplicants(recruitId: recruitId)
        case .showCloseModal(let recruitId):
            showCloseModal(recruitId: recruitId)
        }
    }
}

extension RecruitMyPostListHostingController: RecruitDataHostingControllerDelegate {
    func delete(id: Int) {
        rootView.delete(id: id)
    }

    private func showRecruitData(id: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let viewModel = RecruitDataViewModel(
            fetchRecruitDataUseCase: fetchUseCase,
            deleteRecruitDataUseCase: deleteUseCase,
            recruitId: id
        )
        let controller = RecruitDataHostingController(
            rootView: RecruitDataView(viewModel: viewModel),
            delegate: self
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

    private func showApplicants(recruitId: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchRecruitMyPostDataUseCase = DefaultFetchRecruitMyPostDataUseCase(repository: repository)
        let viewModel = RecruitMyPostViewModel(
            fetchRecruitMyPostDataUseCase: fetchRecruitMyPostDataUseCase,
            recruitId: recruitId
        )
        let controller = RecruitMyPostHostingController(
            rootView: RecruitMyPostView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showCloseModal(recruitId: Int) {
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "해당 모집글을 마감하시겠어요?",
                subTitleText: "마감 후에는 더이상 지원자를 받을 수 없습니다."
            ),
            button: .buttons(
                leftButtonTitle: "취소하기",
                rightButtonTitle: "마감하기",
                rightButtonAction: { [weak self] in
                    self?.rootView.close(id: recruitId)
                }
            ),
            layout: .init(width: 320)
        ))
        present(modalViewController, animated: true)
    }
}

extension RecruitMyPostListHostingController {
    private func showFilterBottomSheet(
        _ filterState: RecruitMyPostFilter,
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
