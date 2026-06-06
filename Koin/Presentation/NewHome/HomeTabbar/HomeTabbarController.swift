//
//  HomeTabbarController.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI
import Combine
import SnapKit
import UIKit

@MainActor
final class HomeTabbarController: UITabBarController {
    
    private enum Tab: Int, CaseIterable {
        case home
        case category
        case board
        case profile
        
        var title: String {
            switch self {
            case .home:
                return "홈"
            case .category:
                return "카테고리"
            case .board:
                return "게시판"
            case .profile:
                return "프로필"
            }
        }
        
        var imageAsset: ImageAsset {
            switch self {
            case .home:
                return .tabbarHome
            case .category:
                return .tabbarCategory
            case .board:
                return .tabbarNotice
            case .profile:
                return .tabbarProfile
            }
        }
        
        var item: HomeTabbarItem {
            HomeTabbarItem(title: title, imageAsset: imageAsset)
        }
    }
    
    private lazy var customTabBarView = HomeTabbarView(items: Tab.allCases.map(\.item))
    private var customTabBarHeightConstraint: Constraint?
    private let viewModel: HomeTabbarViewModel
    private let inputSubject = PassthroughSubject<HomeTabbarViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var customTabBarHeight: CGFloat {
        HomeTabbarView.Layout.barHeight + (view.safeAreaInsets.bottom < 0.5 ? HomeTabbarView.Layout.itemTopPadding : view.safeAreaInsets.bottom)
    }
    
    // MARK: - Initializer
    init(
        homeViewController: UIViewController,
        categoryViewController: UIViewController,
        noticeViewController: UIViewController,
        profileViewController: UIViewController,
        viewModel: HomeTabbarViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        let viewControllers = [homeViewController, categoryViewController, noticeViewController, profileViewController]
        let configuredViewControllers = zip(viewControllers, Tab.allCases).map { viewController, tab in
            viewController.tabBarItem = UITabBarItem(title: tab.title, image: nil, selectedImage: nil)
            viewController.additionalSafeAreaInsets.bottom = HomeTabbarView.Layout.barHeight
            return viewController
        }
        setViewControllers(configuredViewControllers, animated: false)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appColor(.newBackground)
        configureCustomTabBar()
        configureNavigationBar()
        bind()
        selectTab(index: Tab.home.rawValue)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCustomTabBarHeight()
        view.bringSubviewToFront(customTabBarView)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateCustomTabBarHeight()
    }
}

extension HomeTabbarController {
    
    private func configureCustomTabBar() {
        tabBar.isHidden = true
        
        customTabBarView.onTapItem = { [weak self] index in
            self?.selectTab(index: index)
        }
        
        view.addSubview(customTabBarView)
        customTabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            customTabBarHeightConstraint = $0.height.equalTo(customTabBarHeight).constraint
        }
    }
    
    private func updateCustomTabBarHeight() {
        customTabBarHeightConstraint?.update(offset: customTabBarHeight)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .sink { _ in }
            .store(in: &subscriptions)
    }
    
    private func selectTab(index: Int) {
        guard Tab(rawValue: index) != nil else { return }
        selectedIndex = index
        customTabBarView.updateSelectedIndex(index)
    }
}

extension HomeTabbarController {

    private func configureNavigationBar() {
        configureNavigationBar(style: .order)
        configureLeftBarItem()
        configureRightBarButton()
    }

    private func configureLeftBarItem() {
        let leftBarButtonStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .center
        }
        leftBarButtonStackView.addArrangedSubview(UIImageView(image: .appImage(asset: .bcsdSymbolLogo)?.resize(to: .init(width: 46, height: 37))))
        leftBarButtonStackView.addArrangedSubview(UIImageView(image: .appImage(asset: .koinTextLogo)?.resize(to: .init(width: 51, height: 30))))
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonStackView)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    private func configureRightBarButton(hasDot: Bool = false) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: hasDot ? .homeBellDot : .homeBell)?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(navigateToNotification)
        )
    }

    @objc private func navigateToNotification() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.notification, .click, "알림 아이콘"))
        let viewModel = NotificationViewModel(
            fetchNotificationListUseCase: MockFetchNotificationListUseCase()
        )
        let viewController = NotificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
