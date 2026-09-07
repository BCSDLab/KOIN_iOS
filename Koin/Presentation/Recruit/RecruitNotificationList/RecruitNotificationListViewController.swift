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

    // MARK: - UI Components
    private let notificationListView = NotificationListView()

    // MARK: - Initialization
    init(viewModel: RecruitNotificationListViewModel) {
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
    }
}

extension RecruitNotificationListViewController {
    private func updateNotificationList(_ notificationList: RecruitNotificationList) {
        self.notificationList = notificationList
        
        notificationListView.update(
            items: notificationList.notifications.map {
                $0.toNotificationRowModel()
            }
        )
    }
    private func handleNavigation(id: Int) {
        guard let notification = notificationList?.notifications.first(where: { $0.id == id }) else {
            return
        }
        // TODO
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
