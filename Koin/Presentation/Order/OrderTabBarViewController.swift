//
//  OrderTabBarViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit

final class OrderTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private var selectedShopID: Int?
    private var initialTabIndex: Int
    
    init(selectedShopID: Int? = nil, initialTabIndex: Int = 0) {
        self.selectedShopID = selectedShopID
        self.initialTabIndex = initialTabIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupNavigationRightButton()
        configureController()
        setupTabBarAppearance()
        
        selectedIndex = initialTabIndex
        updateNavigationTitle(for: initialTabIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .order)
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
        let orderCartWebViewController = OrderCartWebViewController()
        orderCartWebViewController.title = "장바구니"
        navigationController?.pushViewController(orderCartWebViewController, animated: true)
    }

    // MARK: - Configure TabBar
    private func configureController() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let orderService = DefaultOrderService()
        let orderRepository = DefaultOrderShopRepository(service: orderService)
        
        let orderHomeViewModel = OrderHomeViewModel(
            fetchShopCategoryListUseCase: DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository),
            fetchOrderShopListUseCase: DefaultFetchOrderShopListUseCase(orderShopRepository: orderRepository),
            searchOrderShopUseCase: DefaultSearchOrderShopUseCase(orderShopRepository: orderRepository),
            selectedId: initialTabIndex == 0 ? selectedShopID ?? 1 : 1
        )
        
        let orderHomeViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .orderHomeTabBar),
            rootViewController: OrderHomeViewController(viewModel: orderHomeViewModel),
            title: "홈"
        )
        
        let shopViewModel = ShopViewModel(
            fetchShopListUseCase: DefaultFetchShopListUseCase(shopRepository: shopRepository),
            fetchEventListUseCase: DefaultFetchEventListUseCase(shopRepository: shopRepository),
            fetchShopCategoryListUseCase: DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository),
            searchShopUseCase: DefaultSearchShopUseCase(shopRepository: shopRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            getUserScreenTimeUseCase: DefaultGetUserScreenTimeUseCase(),
            fetchShopBenefitUseCase: DefaultFetchShopBenefitUseCase(shopRepository: shopRepository),
            fetchBeneficialShopUseCase: DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository),
            selectedId: initialTabIndex == 1 ? selectedShopID ?? 0 : 0
        )
        
        let shopViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .shopTabBar),
            rootViewController: ShopViewController(viewModel: shopViewModel),
            title: "주변상점"
        )

        let historyViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .orderDetailTabBar),
            rootViewController: OrderHistoryViewController(),
            title: "주문내역"
        )

        viewControllers = [orderHomeViewController, shopViewController, historyViewController]

        tabBar.tintColor = UIColor.appColor(.new500)
        tabBar.unselectedItemTintColor = UIColor.appColor(.neutral300)
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        updateNavigationTitle(for: selectedIndex)
    }

    // MARK: - Appearance
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        let selectedTitleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.appFont(.pretendardBold, size: 12)
        ]
        let normalTitleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appColor(.neutral300),
            .font: UIFont.appFont(.pretendardBold, size: 12)
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTitleAttrs
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = normalTitleAttrs

        appearance.inlineLayoutAppearance.selected.titleTextAttributes  = selectedTitleAttrs
        appearance.inlineLayoutAppearance.normal.titleTextAttributes    = normalTitleAttrs
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedTitleAttrs
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes   = normalTitleAttrs

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = UIColor.appColor(.new500)
        tabBar.unselectedItemTintColor = UIColor.appColor(.neutral300)
    }

    // MARK: - Helper
    private func tabBarNavigationController(
        image: UIImage?,
        rootViewController: UIViewController,
        title: String
    ) -> UINavigationController {
        let nav = RootHidingNavigationController(rootViewController: rootViewController)

        let template = (image ?? UIImage()).withRenderingMode(.alwaysTemplate)
        nav.tabBarItem = UITabBarItem(title: title,
                                      image: template,
                                      selectedImage: template)
        return nav
    }
    
    private func updateNavigationTitle(for index: Int) {
        switch index {
        case 0: navigationItem.title = "주문"
        case 1: navigationItem.title = "주변 상점"
        case 2: navigationItem.title = "주문 내역"
        default: break
        }
    }
}

final class RootHidingNavigationController: UINavigationController,
                                            UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        let isRoot = viewController === viewControllers.first
        setNavigationBarHidden(isRoot, animated: animated)
    }
}
