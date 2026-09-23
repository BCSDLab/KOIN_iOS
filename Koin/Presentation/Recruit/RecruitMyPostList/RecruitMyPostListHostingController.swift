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
            showToastMessage(message: message, bottomInset: 24)
        case .showRecruitData(let id):
            showRecruitData(id: id)
        case .showChat(let chatRoomId):
            showChat(chatRoomId: chatRoomId)
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
        let repository = MockRecruitRepository()
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

    private func showChat(chatRoomId: Int) {
        // TODO: 채팅 화면 연결
    }

    private func showApplicants(recruitId: Int) {
        // TODO: 지원자 관리 화면 연결
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
