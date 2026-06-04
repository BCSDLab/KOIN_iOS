//
//  NotificationViewController.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: NotificationViewModel
    private let inputSubject = PassthroughSubject<NotificationViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    private let notificationTableView = NotificationTableView()
    private let refreshControl = UIRefreshControl()
    
    private let emptyView = NotificationEmptyView().then {
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    // MARK: - Initialization
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        setAddTargets()
        bind()
        inputSubject.send(.viewDidLoad)
    }
}

// MARK: - Bind

private extension NotificationViewController {
    func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .updateNotifications(let notifications):
                    self.notificationTableView.update(notifications: notifications)
                    self.updateStateViews(isEmpty: notifications.isEmpty)
                    self.notificationTableView.updateFooterPosition()

                case .updateLoading(let isLoading):
                    self.updateLoadingState(isLoading)

                case .showToast(let message):
                    showToastMessage(message: message)
                }
            }
            .store(in: &subscriptions)
            
        notificationTableView.deletePublisher
            .sink { [weak self] id in
                guard let self else { return }
                self.inputSubject.send(.deleteNotification(id: id))
                self.updateStateViews(isEmpty: self.notificationTableView.isEmpty)
            }
            .store(in: &subscriptions)
    }

    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        updateStateViews(isEmpty: notificationTableView.isEmpty)
    }

    func updateStateViews(isEmpty: Bool) {
        let shouldShowEmpty = isEmpty && !loadingIndicator.isAnimating
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) { [weak self] in
            self?.emptyView.alpha = shouldShowEmpty ? 1 : 0
            self?.notificationTableView.alpha = shouldShowEmpty ? 0 : 1
        } completion: { [weak self] _ in
            self?.emptyView.isHidden = !shouldShowEmpty
            self?.notificationTableView.isHidden = shouldShowEmpty
        }

        if !shouldShowEmpty {
            notificationTableView.updateFooterPosition()
        }
    }
}

// MARK: - Action

private extension NotificationViewController {
    @objc func didTapManageNoticeKeyword() {
        navigationController?.pushViewController(makeManageNoticeKeywordViewController(), animated: true)
    }
    
    @objc func didPullToRefresh() {
        inputSubject.send(.reload)
    }

    private func makeManageNoticeKeywordViewController() -> UIViewController {
        let noticeListRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ManageNoticeKeywordViewModel(
            addNotificationKeywordUseCase: DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeListRepository),
            deleteNotificationKeywordUseCase: DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeListRepository),
            fetchNotificationKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeListRepository),
            fetchRecommendedKeywordUseCase: DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeListRepository),
            changeNotiUseCase: DefaultChangeNotiUseCase(notiRepository: notiRepository),
            fetchNotiListUseCase: DefaultFetchNotiListUseCase(notiRepository: notiRepository),
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return ManageNoticeKeywordViewController(viewModel: viewModel)
    }
}

// MARK: - Configure

private extension NotificationViewController {
    
    private func setAddTargets() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func configureNavigationBar() {
        title = "알림"
        configureNavigationBar(style: .empty)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "알림설정")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "알림설정",
            style: .plain,
            target: self,
            action: #selector(didTapManageNoticeKeyword)
        )
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .font: UIFont.appFont(.pretendardMedium, size: 13),
            .foregroundColor: UIColor.ColorSystem.Neutral.gray600
        ], for: .normal)
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .font: UIFont.appFont(.pretendardMedium, size: 13),
            .foregroundColor: UIColor.ColorSystem.Neutral.gray600
        ], for: .selected)
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.ColorSystem.Neutral.gray0
        
        notificationTableView.refreshControl = refreshControl
    }
    
    private func setUpLayouts() {
        [notificationTableView, emptyView, loadingIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        notificationTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
