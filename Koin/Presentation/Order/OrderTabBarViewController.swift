//
//  OrderTabBarViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit

final class OrderTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private var selectedShopId: Int?
    private var initialTabIndex: Int
    
    init(selectedShopID: Int? = nil, initialTabIndex: Int = 0) {
        self.selectedShopId = selectedShopID
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
        if UserDataManager.shared.userId.isEmpty {
            let popupView = OrderLoginPopupView()

            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {

                popupView.frame = window.bounds

                popupView.loginButtonAction = {
                    let loginViewController = LoginViewController(
                        viewModel: LoginViewModel(
                            loginUseCase: DefaultLoginUseCase(
                                userRepository: DefaultUserRepository(service: DefaultUserService())
                            ),
                            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
                            )
                        )
                    )
                    loginViewController.title = "로그인"
                    self.navigationController?.pushViewController(loginViewController, animated: true)
                }

                window.addSubview(popupView)
            }

        } else {
            let orderCartWebViewController = OrderCartWebViewController()
            orderCartWebViewController.title = "장바구니"
            navigationController?.pushViewController(orderCartWebViewController, animated: true)
        }
    }

    // MARK: - Configure TabBar
    private func configureController() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let orderService = DefaultOrderService()
        let orderRepository = DefaultOrderShopRepository(service: orderService)

        let fetchOrderEventShopUseCase = DefaultFetchOrderEventShopUseCase(orderShopRepository: orderRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchOrderShopListUseCase = DefaultFetchOrderShopListUseCase(orderShopRepository: orderRepository)
        let searchOrderShopUseCase = DefaultSearchOrderShopUseCase(orderShopRepository: orderRepository)

        let orderHomeViewModel = OrderHomeViewModel(
            fetchOrderEventShopUseCase: fetchOrderEventShopUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchOrderShopListUseCase: fetchOrderShopListUseCase,
            searchOrderShopUseCase: searchOrderShopUseCase,
            selectedId: selectedShopId ?? 1
        )
        let orderHomeViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .orderHomeTabBar)?.withRenderingMode(.alwaysTemplate),
            rootViewController: OrderHomeViewController(viewModel: orderHomeViewModel),
            title: "홈"
        )

        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchShopEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)

        let shopViewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchShopEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            searchShopUseCase: searchShopUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            selectedId: initialTabIndex == 1 ? selectedShopId ?? 0 : 0
        )
        let shopViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .orderShopTabBar)?.withRenderingMode(.alwaysTemplate),
            rootViewController: ShopViewController(viewModel: shopViewModel),
            title: "주변상점"
        )

        let historyViewController = tabBarNavigationController(
            image: UIImage.appImage(asset: .orderDetailTabBar)?.withRenderingMode(.alwaysTemplate),
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

        for style in [appearance.stackedLayoutAppearance,
                      appearance.inlineLayoutAppearance,
                      appearance.compactInlineLayoutAppearance] {
            style.selected.iconColor = selectedColor
            style.normal.iconColor = unselectedColor
            style.selected.titleTextAttributes = selectedAttrs
            style.normal.titleTextAttributes = normalAttrs
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
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

        if viewController is OrderHomeDetailWebViewController {
            setNavigationBarHidden(true, animated: animated)
        } else {
            let isRoot = viewController === viewControllers.first
            setNavigationBarHidden(isRoot, animated: animated)
        }
    }
}
