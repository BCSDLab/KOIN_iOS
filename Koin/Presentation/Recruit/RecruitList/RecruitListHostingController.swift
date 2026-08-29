//
//  RecruitListHostingController.swift
//  koin
//
//  Created by 홍기정 on 8/28/26.
//

import SwiftUI

final class RecruitListHostingController: UIHostingController<RecruitListView>, HostingControllerProtocol {
    
    // MARK: - UI Components
    private let notificationBarButton = UIButton(type: .system)
    private let profileBarButton = UIButton(type: .system)
    private let rightBarButtonsView = UIView()
    private lazy var rightBarButton = UIBarButtonItem(customView: rightBarButtonsView)
    
    // MARK: - Initializer
    override init(rootView: RecruitListView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
        title = "팀원모집"
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
        navigationItem.rightBarButtonItem = rightBarButton
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }
    
    // MARK: Public
    func execute(action: RootView.Action) {
        switch action {
        case .configureRightButtons(let hasNotification):
            updateNotificationBarButton(hasNotification)
        case .showFilterBottomSheet(let filterState, let onApplyTapped):
            showFilterBottomSheet(filterState, onApplyTapped)
        case .showToast(let message):
            showToastMessage(message: message)
        case .showLoginToast:
            showLoginToast()
        case .showRecruitPost:
            showRecruitPost()
        }
    }
}

extension RecruitListHostingController {
    private func updateNotificationBarButton(_ hasUnreadNotification: Bool) {
        UIView.transition(
            with: notificationBarButton,
            duration: 0.2,
            options: [
                .transitionCrossDissolve,
                .beginFromCurrentState
            ]
        ) { [weak self] in
            self?.notificationBarButton.setImage(
                .appImage(asset: hasUnreadNotification ? .recruitBellDot : .recruitBell)?.withRenderingMode(.alwaysOriginal),
                for: .normal
            )
        }
    }
    
    private func showLoginToast() {
        showToastMessageWithButton(
            message: "로그인이 필요한 기능입니다.",
            buttonTitle: "로그인"
        ) { [weak self] in
            self?.navigateToLogin()
        }
        return
    }
    private func showRecruitNotification() {
        // TODO
    }
    private func showRecruitProfile() {
        // TODO
    }
    private func showRecruitPost() {
        // TOOD
    }    
}

extension RecruitListHostingController {
    private func showFilterBottomSheet(
        _ filterState: RecruitListFilter,
        _ onApplyTapped: @escaping ([FilterGroupModel])->Void
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

extension RecruitListHostingController {
    private func setAddTargets() {
        notificationBarButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        profileBarButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }
    
    @objc private func notificationButtonTapped() {
        guard UserDataManager.shared.isLoggedIn else {
            showLoginToast()
            return
        }
        showRecruitNotification()
    }
    
    @objc private func profileButtonTapped() {
        guard UserDataManager.shared.isLoggedIn else {
            showLoginToast()
            return
        }
        showRecruitProfile()
    }
}

extension RecruitListHostingController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        notificationBarButton.do {
            $0.setImage(.appImage(asset: .recruitBell), for: .normal)
        }
        
        profileBarButton.do {
            $0.setImage(.appImage(asset: .recruitProfile), for: .normal)
        }
    }
    
    private func setUpLayouts() {
        [notificationBarButton, profileBarButton].forEach {
            rightBarButtonsView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        notificationBarButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.top.bottom.equalToSuperview()
        }
        profileBarButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalTo(notificationBarButton.snp.trailing)
            $0.top.bottom.trailing.equalToSuperview()
        }
        rightBarButtonsView.snp.makeConstraints {
            $0.width.equalTo(88)
            $0.height.equalTo(44)
        }
    }
}
