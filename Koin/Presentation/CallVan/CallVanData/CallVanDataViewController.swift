//
//  CallVanDataViewController.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanDataViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject = PassthroughSubject<CallVanDataViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: CallVanDataViewModel
    
    // MARK: - UI Components
    private let refreshControl = UIRefreshControl()
    private let scrollView = UIScrollView()
    private let dataView = CallVanDataView()
    private let participantsTableView = CallVanDataTableView()
    private let separatorView = UIView()
    private let enterChatRoomButton = UIButton()
    
    // MARK: - Initializer
    init(viewModel: CallVanDataViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "콜밴팟"
        configureView()
        bind()
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        addGesture()
        setAddTargets()
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.viewWillAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        participantsTableView.closeReportButton()
    }
}

extension CallVanDataViewController {
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .update(callVanData):
                dataView.configure(callVanData: callVanData)
                participantsTableView.configure(participants: callVanData.participants)
            case let .updateBell(alert):
                configureRightBarButton(alert: alert)
            }
            refreshControl.endRefreshing()
        }.store(in: &subscriptions)
        
        participantsTableView.reportButtonTappedPublisher.sink { [weak self] userId in
            self?.navigateToReport(userId)
        }.store(in: &subscriptions)
    }
}

extension CallVanDataViewController {
    
    private func setAddTargets() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        enterChatRoomButton.addTarget(self, action: #selector(enterChatRoomButtonTapped), for: .touchUpInside)
    }
    
    @objc private func refresh() {
        inputSubject.send(.refresh)
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAround))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func enterChatRoomButtonTapped() {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let fetchCallVanChatUseCase = DefaultFetchCallVanChatUseCase(repository: callVanRepository)
        let postCallVanChatUseCase = DefaultPostCallVanChatUseCase(repository: callVanRepository)
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: coreRepository)
        let viewModel = CallVanChatViewModel(
            postId: viewModel.postId,
            fetchCallVanChatUseCase: fetchCallVanChatUseCase,
            postCallVanChatUseCase: postCallVanChatUseCase,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            uploadFileUseCase: uploadFileUseCase)
        let viewController = CallVanChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func didTapAround() {
        participantsTableView.closeReportButton()
    }
}

extension CallVanDataViewController {
    
    private func configureRightBarButton(alert: Bool = false) {
        let image = alert ? UIImage.appImage(asset: .bellNotification) : UIImage.appImage(asset: .bell)
        let bellButton = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(bellButtonTapped))
        navigationItem.rightBarButtonItem = bellButton
    }
    
    @objc private func bellButtonTapped() {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let postNotificationReadUseCase = DefaultPostNotificationReadUseCase(repository: callVanRepository)
        let postAllNotificationsReadUseCase = DefaultPostAllNotificationsReadUseCase(repository: callVanRepository)
        let deleteNotificationUseCase = DefaultDeleteNotificationUseCase(repository: callVanRepository)
        let deleteAllNotificationsUseCase = DefaultDeleteAllNotificationsUseCase(repository: callVanRepository)
        let viewModel = CallVanNotificationViewModel(
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            postNotificationReadUseCase: postNotificationReadUseCase,
            postAllNotificationsReadUseCase: postAllNotificationsReadUseCase,
            deleteNotificationUseCase: deleteNotificationUseCase,
            deleteAllNotificationsUseCase: deleteAllNotificationsUseCase)
        let viewController = CallVanNotificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CallVanDataViewController {
    
    private func navigateToReport(_ userId: Int) {
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: coreRepository)
        let reportCallVanUserUseCase = DefaultReportCallVanUserUseCase(repository: callVanRepository)
        let viewModel = CallVanReportViewModel(
            postId: viewModel.postId,
            reportedUserId: userId,
            uploadFileUseCase: uploadFileUseCase,
            reportCallVanUserUseCase: reportCallVanUserUseCase
        )
        let viewController = CallVanReportReasonViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CallVanDataViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        
        scrollView.do {
            $0.refreshControl = refreshControl
        }
        
        participantsTableView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        enterChatRoomButton.do {
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.setAttributedTitle(NSAttributedString(
                string: "단체 채팅방 입장",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.layer.cornerRadius = 8
        }
    }
    
    private func setUpLayouts() {
        [dataView, participantsTableView].forEach {
            scrollView.addSubview($0)
        }
        [scrollView, separatorView, enterChatRoomButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(separatorView.snp.top)
        }
        dataView.snp.makeConstraints {
            $0.width.equalTo(view)
            $0.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
        }
        participantsTableView.snp.makeConstraints {
            $0.height.equalTo(56 * 8)
            $0.width.equalTo(view)
            $0.top.equalTo(dataView.snp.bottom)
            $0.bottom.leading.trailing.equalTo(scrollView.contentLayoutGuide)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(enterChatRoomButton.snp.top).offset(-24)
        }
        enterChatRoomButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
}
