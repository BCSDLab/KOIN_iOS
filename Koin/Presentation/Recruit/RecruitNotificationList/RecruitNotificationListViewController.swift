//
//  RecruitNotificationListViewController.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit

final class RecruitNotificationListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RecruitNotificationListViewModel
    private let inputSubject = PassthroughSubject<RecruitNotificationListViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var notificationList: RecruitNotificationList?
    private var notificationId: Int?

    // MARK: - UI Components
    private let notificationListView = NotificationListView(behavior: .pagination)

    // MARK: - Initialization
    init(viewModel: RecruitNotificationListViewModel, notificationId: Int? = nil) {
        self.viewModel = viewModel
        self.notificationId = notificationId
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
        bind()
        notificationListView.startLoading()
        inputSubject.send(.viewDidLoad)
        title = "알림"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
}

// MARK: - Bind

private extension RecruitNotificationListViewController {
    func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .updateNotifications(let notificationList):
                    updateNotificationList(notificationList)
                case .showToast(let message):
                    showToastMessage(message: message)
                case .didFinishLoading:
                    notificationListView.stopLoading()
                }
            }
            .store(in: &subscriptions)
        
        notificationListView.deletePublisher
            .sink { [weak self] id in
                guard let self,
                      let id = Int(id) else {
                    return
                }
                self.notificationList?.delete(id: id)
                self.inputSubject.send(.deleteNotification(id: id))
            }
            .store(in: &subscriptions)
        
        notificationListView.itemTappedPublisher
            .sink { [weak self] id in
                guard let self,
                      let id = Int(id) else {
                    return
                }
                self.notificationList?.markAsRead(id: id)
                handleNavigation(id: id)
                inputSubject.send(.didTapNotification(id: id))
            }
            .store(in: &subscriptions)

        notificationListView.refreshPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.reload)
            }
            .store(in: &subscriptions)
        
        notificationListView.reachedBottomPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.loadNextPage)
            }
            .store(in: &subscriptions)
    }
}

extension RecruitNotificationListViewController {
    private func updateNotificationList(_ notificationList: RecruitNotificationList) {
        self.notificationList = notificationList

        notificationListView.update(
            items: notificationList.notifications.map {
                $0.toNotificationRowModel()
            },
            hasNextPage: notificationList.hasNextPage
        )
        tapNotificationIfNeeded()
    }

    /// 푸시알림으로 진입한 경우, 최초 1회 notificationId 와 일치하는 row 를 탭 처리한다.
    private func tapNotificationIfNeeded() {
        guard let notificationId else {
            return
        }
        self.notificationId = nil
        guard let indexPath = notificationListView.indexPath(forNotificationId: String(notificationId)) else {
            return
        }
        notificationListView.tapRow(at: indexPath)
    }
    private func handleNavigation(id: Int) {
        guard let notification = notificationList?.notifications.first(where: { $0.id == id }) else {
            return
        }
        switch notification.targetType {
        case .chatRoom:
            if notification.type == .newChatMessage, let applicationId = notification.applicationId {
                navigateToChat(roomSource: .direct(recruitmentId: notification.recruitmentId, applicationId: applicationId))
            } else if let chatRoomId = notification.chatRoomId {
                navigateToChat(roomSource: .team(recruitmentId: notification.recruitmentId, chatRoomId: chatRoomId))
            }
        case .applicantManagement:
            navigateToApplicantManagement(recruitmentId: notification.recruitmentId)
        case .myApplications:
            navigateToMyApplications()
        case .none:
            return
        }
    }
    
    private func navigateToChat(roomSource: RecruitChatViewModel.RoomSource) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitChatViewModel(
            roomSource: roomSource,
            fetchTeamChatDataUseCase: DefaultFetchRecruitTeamChatDataUseCase(repository: repository),
            fetchDirectChatDataUseCase: DefaultFetchRecruitDirectChatDataUseCase(repository: repository),
            fetchChatMessagesUseCase: DefaultFetchRecruitChatMessagesUseCase(repository: repository),
            postChatMessageUseCase: DefaultPostRecruitChatMessageUseCase(repository: repository),
            uploadFileUseCase: DefaultUploadFileUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        )
        navigationController?.pushViewController(RecruitChatViewController(viewModel: viewModel), animated: true)
    }
    
    private func navigateToApplicantManagement(recruitmentId: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitMyPostViewModel(
            fetchRecruitMyPostDataUseCase: DefaultFetchRecruitMyPostDataUseCase(repository: repository),
            recruitId: recruitmentId
        )
        let controller = RecruitMyPostHostingController(
            rootView: RecruitMyPostView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToMyApplications() {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let viewModel = RecruitMyApplicationListViewModel(
            fetchRecruitMyApplicationListUseCase: DefaultFetchRecruitMyApplicationListUseCase(repository: repository)
        )
        let controller = RecruitMyApplicationListHostingController(
            rootView: RecruitMyApplicationListView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension RecruitNotificationListViewController {
    @objc func rightBarButtonItemTapped() {
        showPopUpView()
    }
    
    private func showPopUpView() {
        let popUpViewController = NotificationPopUpViewController(
            markAllAsRead: { [weak self] in
                self?.inputSubject.send(.markAllAsRead)
                self?.notificationList?.markAllAsRead()
                self?.notificationListView.markAllAsRead()
            },
            deleteAll: { [weak self] in
                self?.inputSubject.send(.deleteAllNotifications)
                self?.notificationList?.deleteAll()
                self?.notificationListView.deleteAll()
            }
        )
        popUpViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(
            popUpViewController,
            animated: false
        )
    }
}

private extension RecruitNotificationListViewController {
    private func configureNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: .threeCircle),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonItemTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.ColorSystem.Neutral.gray0
    }
    
    private func setUpLayouts() {
        view.addSubview(notificationListView)
    }
    
    private func setUpConstraints() {
        notificationListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
