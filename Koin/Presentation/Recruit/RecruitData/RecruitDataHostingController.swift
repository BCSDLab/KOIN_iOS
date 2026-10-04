//
//  RecruitDataHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/12/26.
//

import SwiftUI

protocol RecruitDataHostingControllerDelegate: AnyObject {
    func delete(id: Int)
}

final class RecruitDataHostingController: UIHostingController<RecruitDataView>, HostingControllerProtocol {
    
    // MARK: - Propertoes
    private weak var delegate: RecruitDataHostingControllerDelegate?
    
    // MARK: - Initializer
    init(
        rootView: RecruitDataView,
        delegate: RecruitDataHostingControllerDelegate?
    ) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        self.delegate = delegate
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "팀원 모집"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }
    
    // MARK: - Execute
    func execute(action: RecruitDataView.Action) {
        switch action {
        case .showApplicant:
            navigateToApplicant()
        case .showApply:
            navigateToApply()
        case .didDelete:
            handleDelete()
        case let .showToast(message):
            showToastMessage(message: message, bottomInset: 72)
        case .showLoginToast:
            showLoginToast()
        case .showProfileRequiredToast:
            showProfileRequiredToast()
        case .isAuthor(let isAuthor):
            configureRightBarButton(isAuthor)
        }
    }
}

extension RecruitDataHostingController {
    private func configureRightBarButton(_ isAuthor: Bool) {
        if !isAuthor {
            navigationItem.rightBarButtonItem = nil
        } else {
            let rightBarButtonItem = UIBarButtonItem(
                image: .appImage(asset: .threeCircle),
                style: .plain,
                target: self,
                action: #selector(rightBarButtonItemTapped)
            )
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
}

extension RecruitDataHostingController {
    private func showLoginToast() {
        showToastMessageWithButton(
            message: "로그인이 필요한 기능입니다.",
            buttonTitle: "로그인하기",
            bottomInset: 72
        ) { [weak self] in
            self?.navigateToLogin()
        }
    }
    
    private func showProfileRequiredToast() {
        showToastMessageWithButton(
            message: RecruitApplyBlockReason.profileRequired.toastMessage,
            buttonTitle: "작성하기",
            bottomInset: 72
        ) { [weak self] in
            self?.navigateToProfilePost()
        }
    }
}

extension RecruitDataHostingController {
    @objc private func rightBarButtonItemTapped() {
        let popUpViewController = RecruitDataPopUpViewController(
            onEditButtonTapped: { [weak self] in
                self?.navigateToEdit()
            },
            onDeleteButtonTapped: { [weak self] in
                self?.showDeleteModal()
            }
        )
        popUpViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(
            popUpViewController,
            animated: false
        )
    }
    
    private func showDeleteModal() {
        let onDeleteButtonTapped: ()->Void = { [weak self] in
            self?.rootView.didTapDelete()
        }
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .singleTitle(text: "해당 모집글을 삭제하시겠습니까?"),
            button: .buttons(
                leftButtonTitle: "취소하기",
                leftButtonAction: nil,
                rightButtonTitle: "삭제하기",
                rightButtonAction: onDeleteButtonTapped
            )
        ))
        present(modalViewController, animated: true)
    }
}

extension RecruitDataHostingController {
    private func navigateToApplicant() {
        guard let id = rootView.id else {
            return
        }
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchRecruitMyPostDataUseCase = DefaultFetchRecruitMyPostDataUseCase(repository: repository)
        let viewModel = RecruitMyPostViewModel(
            fetchRecruitMyPostDataUseCase: fetchRecruitMyPostDataUseCase,
            recruitId: id
        )
        let controller = RecruitMyPostHostingController(
            rootView: RecruitMyPostView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    private func navigateToApply() {
        guard let recruit = rootView.data else {
            return
        }
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitApplyViewModel(
            fetchDeptListUseCase: DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService())),
            fetchMyRecruitProfileUseCase: DefaultFetchMyRecruitProfileUseCase(repository: recruitRepository),
            applyRecruitUseCase: DefaultApplyRecruitUseCase(repository: recruitRepository)
        )
        let viewController = RecruitApplyViewController(
            viewModel: viewModel,
            recruit: recruit,
            delegate: self
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToProfilePost() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitProfilePostViewModel(
            fetchDeptListUseCase: DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService())),
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: userRepository),
            postBasicInfoUseCase: DefaultPostBasicInfoUseCase(repository: recruitRepository),
            upsertMyRecruitProfileUseCase: DefaultUpsertMyRecruitProfileUseCase(repository: recruitRepository),
            mode: .post
        )
        let viewController = RecruitProfilePostViewController(viewModel: viewModel) { [weak self] _ in
            self?.rootView.reload()
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func handleDelete() {
        guard let id = rootView.id else {
            return
        }
        delegate?.delete(id: id)
        navigationController?.popViewController(animated: true)
    }
    
    private func navigateToEdit() {
        guard let data = rootView.data else {
            return
        }
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let postRecruitUseCase = DefaultPostRecruitUseCase(repository: recruitRepository)
        let modifyRecruitUseCase = DefaultModifyRecruitUseCase(repository: recruitRepository)
        let viewModel = RecruitPostViewModel(
            mode: .modify(data: data),
            postRecruitUseCase: postRecruitUseCase,
            modifyRecruitUseCase: modifyRecruitUseCase
        )
        let viewController = RecruitPostViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RecruitDataHostingController: RecruitApplyViewControllerDelegate {
    func didApply() {
        rootView.didSubmitApplication()
        showToastMessage(message: "지원서가 제출되었습니다.", bottomInset: 72)
    }
}
