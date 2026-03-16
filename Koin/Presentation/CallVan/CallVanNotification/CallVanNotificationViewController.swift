//
//  CallVanNotificationViewController.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanNotificationViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanNotificationViewModel
    private let inputSubject = PassthroughSubject<CallVanNotificationViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let notificationTableView = CallVanNotificationTableView()
    private let emptyView = CallVanNotificationEmptyView()
    
    // MARK: - Initializer
    init(viewModel: CallVanNotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "알림"
        configureView()
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .updateNotifications(notifications):
                notificationTableView.configure(notifications: notifications)
                emptyView.isHidden = !notifications.isEmpty
            }
        }.store(in: &subscriptions)
        
        notificationTableView.cellTapPublisher.sink { [weak self] (postId, notificationId) in
            self?.inputSubject.send(.setNotificationRead(notificationId))
            self?.navigateToCallVanData(postId)
        }.store(in: &subscriptions)
        
        notificationTableView.deleteNotificationPublisher.sink { [weak self] notificationId in
            self?.inputSubject.send(.deleteNotification(notificationId))
        }.store(in: &subscriptions)
        
        notificationTableView.emptyNotificationPublisher.sink { [weak self] in
            self?.emptyView.isHidden = false
        }.store(in: &subscriptions)
    }
}

extension CallVanNotificationViewController {
    
    private func navigateToCallVanData(_ postId: Int) {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let viewModel = CallVanDataViewModel(postId: postId, fetchCallVanDataUseCase: fetchCallVanDataUseCase)
        let viewController = CallVanDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CallVanNotificationViewController {
    
    private func configureRightBarButton() {
        let rightBarButton = UIBarButtonItem(
            image: UIImage.appImage(asset: .threeCircle),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func rightBarButtonTapped() {
        let onReadButtonTapped: ()->Void = { [weak self] in
            self?.notificationTableView.markAllNotificationsRead()
            self?.inputSubject.send(.setAllNotificationsRead)
        }
        let onDeleteButtonTapped = { [weak self] in
            guard let self else { return }
            let subTitleLabel = UILabel().then {
                $0.text = "삭제한 알림은 되돌릴 수 없습니다."
                $0.font = UIFont.appFont(.pretendardRegular, size: 14)
                $0.textColor = UIColor.appColor(.neutral600)
            }
            subTitleLabel.snp.makeConstraints {
                $0.height.equalTo(22)
            }
            let onMainButtonTapped = { [weak self] in
                self?.notificationTableView.configure(notifications: [])
                self?.emptyView.isHidden = false
                self?.inputSubject.send(.deleteAllNotifications)
            }
            let contentViewController = CallVanBottomSheetViewController(
                titleText: "알림을 모두 삭제할까요?",
                subTitleLabel: subTitleLabel,
                mainButtonText: "예",
                closeButtonText: "아니요",
                onMainButtonTapped: onMainButtonTapped)
            let bottomSheetViewController = BottomSheetViewController(
                contentViewController: contentViewController,
                defaultHeight: 233 + view.safeAreaInsets.bottom
            )
            bottomSheetViewController.modalTransitionStyle = .crossDissolve
            bottomSheetViewController.modalPresentationStyle = .overFullScreen
            present(bottomSheetViewController, animated: true)
        }
        let dropdownViewController = CallVanNotificationDropdownViewController(
            onReadButtonTapped: onReadButtonTapped,
            onDeleteButtonTapped: onDeleteButtonTapped
        )
        dropdownViewController.modalTransitionStyle = .crossDissolve
        dropdownViewController.modalPresentationStyle = .overFullScreen
        present(dropdownViewController, animated: true)
    }
}

extension CallVanNotificationViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
    }
    
    private func setUpLayouts() {
        [notificationTableView, emptyView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        notificationTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
