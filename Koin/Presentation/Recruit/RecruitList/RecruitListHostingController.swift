//
//  RecruitListHostingController.swift
//  koin
//
//  Created by 홍기정 on 8/28/26.
//

import SwiftUI

final class RecruitListHostingController: UIHostingController<RecruitListView>, HostingControllerProtocol {
    
    // MARK: - Layout
    private var toastMessageBottomInset: CGFloat {
        24 + 43 + 12
    }
    
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
        case .showFilterBottomSheet(let filterState, let onFilterItemTapped, let onResetTapped, let onApplyTapped):
            showFilterBottomSheet(filterState, onFilterItemTapped, onResetTapped, onApplyTapped)
        case .showToast(let message):
            showToastMessage(message: message, bottomInset: toastMessageBottomInset)
        case .showLoginToast:
            showLoginToast()
        case .showProfilePostToast:
            showProfilePostToast()
        case .showRecruitPost:
            showRecruitPost()
        case .showRecruitData(let id):
            showRecruitData(id: id)
        }
    }
}

extension RecruitListHostingController: RecruitDataHostingControllerDelegate {
    func delete(id: Int) {
        rootView.delete(id: id)
    }
    
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
            delegate: self
        )
        navigationController?.pushViewController(controller, animated: true)
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
            buttonTitle: "로그인",
            bottomInset: toastMessageBottomInset
        ) { [weak self] in
            self?.navigateToLogin()
        }
        return
    }
    
    private func showProfilePostToast() {
        showToastMessageWithButton(
            message: "팀원 모집 프로필이 필요합니다.",
            buttonTitle: "작성하기",
            bottomInset: toastMessageBottomInset
        ) { [weak self] in
            self?.showProfilePost()
        }
        return
    }
    
    private func showRecruitNotificationList() {
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchRecruitNotificationListUseCase = DefaultFetchRecruitNotificationListUseCase(repository: recruitRepository)
        let markAsReadRecruitNotificationUseCase = DefaultMarkAsReadRecruitNotificationUseCase(repository: recruitRepository)
        let deleteRecruitNotificationUseCase = DefaultDeleteRecruitNotificationUseCase(repository: recruitRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitNotificationListViewModel(
            fetchRecruitNotificationListUseCase: fetchRecruitNotificationListUseCase,
            markAsReadRecruitNotificationUseCase: markAsReadRecruitNotificationUseCase,
            deleteRecruitNotificationUseCase: deleteRecruitNotificationUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = RecruitNotificationListViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func showRecruitProfile() {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchMyRecruitProfileUseCase = DefaultFetchMyRecruitProfileUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitProfileViewModel(
            fetchMyRecruitProfileUseCase: fetchMyRecruitProfileUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = RecruitProfileHostingController(
            rootView: RecruitProfileView(viewModel: viewModel)
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func showRecruitPost() {
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let postRecruitUseCase = DefaultPostRecruitUseCase(repository: recruitRepository)
        let modifyRecruitUseCase = DefaultModifyRecruitUseCase(repository: recruitRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitPostViewModel(
            mode: .post,
            postRecruitUseCase: postRecruitUseCase,
            modifyRecruitUseCase: modifyRecruitUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = RecruitPostViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func showProfilePost() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitProfilePostViewModel(
            fetchDeptListUseCase: DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService())),
            fetchBasicInfoUseCase: DefaultFetchBasicInfoUseCase(repository: userRepository),
            modifyBasicInfoUseCase: DefaultModifyBasicInfoUseCase(repository: userRepository),
            upsertMyRecruitProfileUseCase: DefaultUpsertMyRecruitProfileUseCase(repository: recruitRepository),
            mode: .post
        )
        let viewController = RecruitProfilePostViewController(viewModel: viewModel) { [weak self] profile in
            self?.rootView.update(profile: profile)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RecruitListHostingController {
    private func showFilterBottomSheet(
        _ filterState: RecruitListFilter,
        _ onFilterItemTapped: @escaping (Int, FilterItemModel)->Bool,
        _ onResetTapped: @escaping ()->Void,
        _ onApplyTapped: @escaping ([FilterGroupModel])->Void
    ) {
        let filterBottomSheetView = FilterBottomSheetView(
            groupModels: filterState.toGroupModels(),
            onFilterItemTapped: onFilterItemTapped,
            onResetTapped: onResetTapped,
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
        rootView.makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.teamRecruitmentNotification,
            category: .click,
            value: "알림"
        )
        showRecruitNotificationList()
    }
    
    @objc private func profileButtonTapped() {
        guard UserDataManager.shared.isLoggedIn else {
            showLoginToast()
            return
        }
        rootView.makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.teamRecruitmentProfile,
            category: .click,
            value: "프로필"
        )
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
