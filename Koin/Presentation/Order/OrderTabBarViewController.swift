//
//  OrderTabBarViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import Combine

final class OrderTabBarViewController: UITabBarController {
    
    // MARK: - Properties
    private var selectedShopId: Int
    private var selectedTabIndex: Int
    private var subscriptions: Set<AnyCancellable> = []
    private var isViewLoadedFirst: Bool = true
    
    // MARK: - UI Components
    private let dummyNavigationBar = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
    }
    
    // MARK: - Initialization
    init(selectedShopId: Int = 1, initialTabIndex: Int = 0) {
        self.selectedShopId = selectedShopId
        self.selectedTabIndex = initialTabIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureView()
        // setupNavigationRightButton() // MARK: 주변상점 우선 배포
        setupTabBarAppearance()
        updateNavigationTitle(for: selectedTabIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .transparent)
        
        if let navigationController {
            let navigationBarHeight: CGFloat = UIApplication.topSafeAreaHeight() + navigationController.navigationBar.frame.height
            dummyNavigationBar.snp.updateConstraints {
                $0.height.equalTo(navigationBarHeight)
            }
        }        
        
        if isViewLoadedFirst {
            configureController()
            selectedIndex = selectedTabIndex
            isViewLoadedFirst = false
        }
    }

    // MARK: - Navigation Right Bar Button
    private func setupNavigationRightButton() {
        let cartImage = UIImage.appImage(asset: .shoppingCart)?
            .withRenderingMode(.alwaysTemplate)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: cartImage,
            style: .plain,
            target: self,
            action: #selector(didTapCart)
        )
    }

    @objc private func didTapCart() {
        guard !UserDataManager.shared.userId.isEmpty else {
            showLoginPopup()
            return
        }
        
        let orderCartWebViewController = OrderCartWebViewController()
        orderCartWebViewController.title = "장바구니"
        navigationController?.pushViewController(orderCartWebViewController, animated: true)
    }
    
    private func showLoginPopup() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow }) else { return }
        
        let popupView = OrderLoginPopupView()
        popupView.frame = window.bounds
        
        popupView.loginButtonAction = { [weak self] in
            self?.navigateToLogin()
        }
        
        window.addSubview(popupView)
    }

    // MARK: - Configure TabBar
    private func configureController() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let orderService = DefaultOrderService()
        let orderRepository = DefaultOrderShopRepository(service: orderService)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        
        let orderHomeViewController = makeOrderHomeViewController(
            orderRepository: orderRepository,
            shopRepository: shopRepository
        )
        
        let shopViewController = makeShopViewController(shopRepository: shopRepository)
        
        let orderHistoryViewController = makeOrderHistoryViewController(
            orderService: orderService,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase
        )
        
        viewControllers = [orderHomeViewController, shopViewController, orderHistoryViewController]
        
        configureTabBarItems()
    }
    
    private func makeOrderHomeViewController(
        orderRepository: OrderShopRepository,
        shopRepository: ShopRepository
    ) -> UIViewController {
        let fetchOrderEventShopUseCase = DefaultFetchOrderEventShopUseCase(
            orderShopRepository: orderRepository
        )
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(
            shopRepository: shopRepository
        )
        let fetchOrderShopListUseCase = DefaultFetchOrderShopListUseCase(
            orderShopRepository: orderRepository
        )
        let searchOrderShopUseCase = DefaultSearchOrderShopUseCase(
            orderShopRepository: orderRepository
        )
        let fetchOrderTrackingUseCase = DefaultFetchOrderInProgressUseCase(
            orderShopRepository: orderRepository
        )

        let viewModel = OrderHomeViewModel(
            fetchOrderEventShopUseCase: fetchOrderEventShopUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchOrderShopListUseCase: fetchOrderShopListUseCase,
            fetchOrderTrackingUseCase: fetchOrderTrackingUseCase,
            searchOrderShopUseCase: searchOrderShopUseCase,
            selectedId: selectedShopId
        )
        
        let viewController = OrderHomeViewController(
            viewModel: viewModel,
            navigationControllerDelegate: navigationController
        )
        
        return viewController
    }
    
    private func makeShopViewController(shopRepository: ShopRepository) -> UIViewController {
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(
            shopRepository: shopRepository
        )
        let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(
            shopRepository: shopRepository
        )
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()

        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            selectedId: selectedTabIndex == 1 ? selectedShopId : 0
        )

        let viewController = ShopViewController(
            viewModel: viewModel,
            navigationControllerDelegate: navigationController
        )
        
        return viewController
    }
    
    private func makeOrderHistoryViewController(
        orderService: OrderService,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    ) -> UIViewController {
        let fetchOrderHistoryUseCase = DefaultFetchOrderHistoryUseCase(
            repository: DefaultOrderHistoryRepository(service: orderService)
        )

        let viewModel = OrderHistoryViewModel(
            fetchHistory: fetchOrderHistoryUseCase,
            orderService: orderService,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase
        )

        let viewController = OrderHistoryViewController(viewModel: viewModel)
        return viewController
    }
    
    private func configureTabBarItems() {
        tabBar.tintColor = UIColor.appColor(.new500)
        tabBar.unselectedItemTintColor = UIColor.appColor(.neutral300)
        
        guard let items = tabBar.items, items.count == 3 else { return }
        
        items[0].image = UIImage.appImage(asset: .orderHomeTabBar)?
            .withRenderingMode(.alwaysTemplate)
        items[0].title = "홈"
        
        items[1].image = UIImage.appImage(asset: .orderShopTabBar)?
            .withRenderingMode(.alwaysTemplate)
        items[1].title = "주변상점"
        
        items[2].image = UIImage.appImage(asset: .orderDetailTabBar)?
            .withRenderingMode(.alwaysTemplate)
        items[2].title = "주문내역"
    }
    
    // MARK: - Appearance
    private func setupTabBarAppearance() {
        self.tabBar.isHidden = true
        /*
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        let selectedColor = UIColor.appColor(.new500)
        let unselectedColor = UIColor.appColor(.neutral300)

        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.appFont(.pretendardBold, size: 12)
        ]
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: unselectedColor,
            .font: UIFont.appFont(.pretendardBold, size: 12)
        ]

        for style in [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ] {
            style.selected.iconColor = selectedColor
            style.normal.iconColor = unselectedColor
            style.selected.titleTextAttributes = selectedAttrs
            style.normal.titleTextAttributes = normalAttrs
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
         */
    }

    // MARK: - Navigation Title
    private func updateNavigationTitle(for index: Int) {
        switch index {
        case 0: navigationItem.title = "주문"
        case 1: navigationItem.title = "주변 상점"
        case 2: navigationItem.title = "주문 내역"
        default: break
        }
    }
    
    // MARK: - Public Methods
    func goToHistory(initialSegment: Int) {
        let historyTabIndex = 2
        selectedIndex = historyTabIndex
        updateNavigationTitle(for: historyTabIndex)

        guard let historyVC = viewControllers?[historyTabIndex] as? OrderHistoryViewController else {
            return
        }

        historyVC.loadViewIfNeeded()
        historyVC.setInitialTab(initialSegment)
    }
}

// MARK: - UITabBarControllerDelegate
extension OrderTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        selectedTabIndex = tabBarController.selectedIndex
        updateNavigationTitle(for: selectedIndex)
    }
}

extension OrderTabBarViewController {
    
    private func configureView() {
        [dummyNavigationBar].forEach {
            view.addSubview($0)
        }
        dummyNavigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
}
