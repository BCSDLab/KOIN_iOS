//
//  OrderCartViewController.swift
//  koin
//
//  Created by 홍기정 on 9/25/25.
//

import UIKit
import Combine

final class OrderCartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OrderCartViewModel
    private let inputSubject = PassthroughSubject<OrderCartViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let backCategoryName: String
    
    // MARK: - UI Components
    private let orderCartTableHeaderView = OrderCartTableHeaderView()
    private let orderCartEmptyView = OrderCartEmptyView().then {
        $0.isHidden = true
    }
    private let orderCartTableView = OrderCartTableView().then {
        $0.sectionHeaderTopPadding = 0
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.sectionFooterHeight = .zero
        $0.isHidden = true
    }
    private let orderCartBottomSheet = OrderCartBottomSheet().then {
        $0.isHidden = true
    }
    private let resetCartPopUpView = OrderCartResetCartPopUpView()
    private let loginPopUpView = OrderCartLoginPopUpView().then {
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init(viewModel: OrderCartViewModel, backCategoryName: String) {
        self.viewModel = viewModel
        self.backCategoryName = backCategoryName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRightBarButton()
        configureNavigationBar(style: .order)
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject).sink { [weak self] output in
            guard let self = self else {
                return
            }
            switch output {
            case .updateCart(let cart, let isFromDelivery):
                self.updateCart(cart: cart, isFromDelivery: isFromDelivery)
            case .updateSegment(let isDeliveryAvailable, let isTakeOutAvailable):
                self.updateSegment(isDeliveryAvailable: isDeliveryAvailable, isTakeOutAvailable: isTakeOutAvailable)
            case .removeItemFromTableView(let cartMenuItemId):
                self.orderCartTableView.removeItem(cartMenuItemId: cartMenuItemId)
            case .emptyCart:
                self.emptyCart()
            case .showLoginPopUpView:
                self.showLoginPopUpView()
            case .showToast(let message):
                showToast(message: message)
            }
        }
        .store(in: &subscriptions)
        
        
        // MARK: - TableView - 가게 상세페이지로 이동
        orderCartTableView.moveToShopPublisher.sink { [weak self] in
            guard let self = self,
                  let orderableShopId = self.viewModel.orderableShopId,
                  let shopName = self.viewModel.shopName else {
                return
            }
            let service = DefaultOrderService()
            let repository = DefaultOrderShopRepository(service: service)
            let fetchOrderShopSummaryUseCase = DefaultFetchOrderShopSummaryUseCase(repository: repository)
            let fetchOrderShopMenusUseCase = DefaultFetchOrderShopMenusUseCase(repository: repository)
            let fetchOrderShopMenusGroupsUseCase = DefaultFetchOrderShopMenusGroupsUseCase(repository: repository)
            let fetchCartSummaryUseCase = DefaultFetchCartSummaryUseCase(repository: repository)
            let fetchCartUseCase = DefaultFetchCartUseCase(repository: repository)
            let fetchCartItemsCountUseCase = DefaultFetchCartItemsCountUseCase(repository: repository)
            let resetCartUseCase = DefaultResetCartUseCase(repository: repository)
            let fetchOrderMenuUseCase = DefaultFetchOrderMenuUseCase(repository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            let fetchOrderShopDetailUseCase = DefaultFetchOrderShopDetailUseCase(repository: repository)
            let viewModel = ShopSummaryViewModel(fetchOrderShopSummaryUseCase: fetchOrderShopSummaryUseCase,
                                                fetchOrderShopMenusUseCase: fetchOrderShopMenusUseCase,
                                                fetchOrderShopMenusGroupsUseCase: fetchOrderShopMenusGroupsUseCase,
                                                fetchCartSummaryUseCase: fetchCartSummaryUseCase,
                                                fetchCartUseCase: fetchCartUseCase,
                                                fetchCartItemsCountUseCase: fetchCartItemsCountUseCase,
                                                resetCartUseCase: resetCartUseCase,
                                                fetchOrderMenuUseCase: fetchOrderMenuUseCase,
                                                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                                                getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                                                fetchOrderShopDetailUseCase: fetchOrderShopDetailUseCase,
                                                orderableShopId: orderableShopId,
                                                shopName: shopName)
            let viewController = ShopSummaryViewController(viewModel: viewModel, backCategoryName: self.backCategoryName)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        .store(in: &subscriptions)
        
        orderCartTableView.addQuantityPublisher.sink { [weak self] cartMenuItemId in
            print("add quantity")
        }
        .store(in: &subscriptions)
        
        orderCartTableView.minusQuantityPublisher.sink { [weak self] cartMenuItemId in
            print("minus quantity")
        }
        .store(in: &subscriptions)
        orderCartTableView.deleteItemPublisher.sink { [weak self] cartMenuItemId in
            self?.inputSubject.send(.deleteItem(cartMenuItemId: cartMenuItemId))
        }
        .store(in: &subscriptions)
        orderCartTableView.changeOptionPublisher.sink { [weak self] cartMenuItemId in
            print("change opotion")
        }
        .store(in: &subscriptions)
        
        orderCartTableView.emptyCartPublisher.sink { [weak self] in
            self?.emptyCart()
        }
        .store(in: &subscriptions)
        
        // MARK: - bottomSheet
        orderCartBottomSheet.bottomSheetButtonTappedPublisher.sink { [weak self] in
            self?.orderButtonTapped()
        }
        .store(in: &subscriptions)
        
        // MARK: - Empty View
        orderCartEmptyView.addMenuButtonTappedPublisher.sink { [weak self] in
            self?.popToOrderTabbarViewController()
        }
        .store(in: &subscriptions)
        
        // MARK: - TableHeaderView - 배달/포장 전환
        orderCartTableHeaderView.buttonDeliveryTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.fetchCartDelivery)
        }
        .store(in: &subscriptions)
        orderCartTableHeaderView.buttonTakeOutTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.fetchCartTakeOut)
        }
        .store(in: &subscriptions)
        
        // MARK: - resetCartPopupView
        resetCartPopUpView.rightButtonTappedPublisher.sink { [weak self] in
            self?.inputSubject.send(.resetCart)
        }
        .store(in: &subscriptions)
        
        // MARK: - loginPopUpView
        loginPopUpView.rightButtonTappedPublisher.sink { [weak self] in
            self?.navigateToLogin()
        }
        .store(in: &subscriptions)
    }
}

extension OrderCartViewController {
    
    private func configureRightBarButton() {
        let rightBarButton = UIBarButtonItem(title: "전체삭제", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardSemiBold, size: 14)
        ],for: .normal)
        rightBarButton.setTitleTextAttributes([
            .foregroundColor: UIColor.appColor(.new500),
            .font: UIFont.appFont(.pretendardSemiBold, size: 14)
        ],for: .highlighted)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    // MARK: - @objc
    @objc private func rightBarButtonTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        resetCartPopUpView.frame = window.bounds
        window.addSubview(resetCartPopUpView)
    }
}

extension OrderCartViewController {
    
    // MARK: - show popUpView
    private func showLoginPopUpView() {
        
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
    }
}

extension OrderCartViewController {
    
    private func updateCart(cart: Cart, isFromDelivery: Bool) {
        if cart.items.isEmpty {
            self.orderCartEmptyView.isHidden = false
            self.orderCartTableView.isHidden = true
            self.orderCartBottomSheet.isHidden = true
        }
        else {
            self.orderCartEmptyView.isHidden = true
            self.orderCartTableView.isHidden = false
            self.orderCartBottomSheet.isHidden = false
            self.orderCartTableView.configure(cart: cart)
            self.orderCartBottomSheet.configure(shopMinimumOrderAmount: cart.shopMinimumOrderAmount,
                                                itemsAmount: cart.itemsAmount,
                                                finalPaymentAmount: cart.finalPaymentAmount,
                                                itemsCount: cart.items.count,
                                                isFromDelivery: isFromDelivery)
        }
    }

    private func updateSegment(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool) {
        orderCartTableHeaderView.configure(isDeliveryAvailable: isDeliveryAvailable, isTakeOutAvailable: isTakeOutAvailable)
        orderCartTableHeaderView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: isDeliveryAvailable && isTakeOutAvailable ? 62 : 62+25)
    }
    
    private func orderButtonTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        resetCartPopUpView.frame = window.bounds
        window.addSubview(resetCartPopUpView)
    }
    
    private func emptyCart() {
        orderCartTableView.isHidden = true
        orderCartEmptyView.isHidden = false
        orderCartBottomSheet.isHidden = true
    }
    
    private func popToOrderTabbarViewController() {
        navigationController?.viewControllers.forEach {
            if $0 is OrderTabBarViewController {
                navigationController?.popToViewController($0, animated: true)
                return
            }
        }
    }
}

extension OrderCartViewController {
    
    private func setUpLayouts() {
        [orderCartEmptyView, orderCartTableView, orderCartBottomSheet].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        orderCartEmptyView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        orderCartBottomSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIApplication.hasHomeButton() ? 72 : 106)
        }
        orderCartTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(orderCartBottomSheet.snp.top)
        }
    }
    
    private func setUpTableHeaderView() {
        orderCartTableView.tableHeaderView = orderCartTableHeaderView
    }
    
    private func configureView() {
        view.backgroundColor = .appColor(.newBackground)
        setUpTableHeaderView()
        setUpLayouts()
        setUpConstraints()
    }
}
