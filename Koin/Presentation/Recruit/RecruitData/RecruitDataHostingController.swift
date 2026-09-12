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
            showToastMessage(message: message)
        case .showLoginToast:
            showLoginToast()
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
            buttonTitle: "로그인하기"
        ) { [weak self] in
            self?.navigateToLogin()
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
        // TODO: show applicant
    }
    private func navigateToApply() {
        guard let id = rootView.id else {
            return
        }
        // TODO: show apply
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
        let recruitRepository = MockRecruitRepository()
        let postRecruitUseCase = DefaultPostRecruitUseCase(repository: recruitRepository)
        let modifyRecruitUseCase = DefaultModifyRecruitUseCase(repository: recruitRepository)
        let viewModel = RecruitPostViewModel(
            postType: .modify(data: data),
            postRecruitUseCase: postRecruitUseCase,
            modifyRecruitUseCase: modifyRecruitUseCase
        )
        let viewController = RecruitPostViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
