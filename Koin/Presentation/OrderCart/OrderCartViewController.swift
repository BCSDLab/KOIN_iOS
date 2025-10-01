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
    private var orderableShopId: Int? = nil
    
    // MARK: - Components
    private let emptyView = EmptyView().then {
        $0.isHidden = true
    }
    private let tableView = OrderCartTableView().then {
        $0.sectionHeaderTopPadding = 0
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.sectionFooterHeight = .zero
    }
    private let bottomSheet = OrderCartBottomSheet()
    
    // MARK: - Initializer
    init(viewModel: OrderCartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
            switch output {
            case .updateCart(let cart):
                self?.orderableShopId = cart.orderableShopId
                self?.tableView.configure(cart: cart)
                self?.bottomSheet.configure(shopMinimumOrderAmount: cart.shopMinimumOrderAmount, totalAmount: cart.totalAmount, finalPaymentAmount: cart.finalPaymentAmount, itemsCount: cart.items.count)
            }
        }
        .store(in: &subscriptions)
        
        
        // MARK: - TableView
        tableView.moveToShopPublisher.sink { [weak self] in
            guard let self = self, let orderableShopId = self.orderableShopId else {
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
            let viewModel = ShopDetailViewModel(fetchOrderShopSummaryUseCase: fetchOrderShopSummaryUseCase,
                                                fetchOrderShopMenusUseCase: fetchOrderShopMenusUseCase,
                                                fetchOrderShopMenusGroupsUseCase: fetchOrderShopMenusGroupsUseCase,
                                                fetchCartSummaryUseCase: fetchCartSummaryUseCase,
                                                fetchCartUseCase: fetchCartUseCase,
                                                fetchCartItemsCountUseCase: fetchCartItemsCountUseCase,
                                                resetCartUseCase: resetCartUseCase,
                                                orderableShopId: orderableShopId)
            let viewController = ShopDetailViewController(viewModel: viewModel, isFromOrder: true)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        .store(in: &subscriptions)
        
        tableView.addQuantityPublisher.sink { [weak self] cartMenuItemId in
            print("add quantity")
        }
        .store(in: &subscriptions)
        
        tableView.minusQuantityPublisher.sink { [weak self] cartMenuItemId in
            print("minus quantity")
        }
        .store(in: &subscriptions)
        tableView.deleteItemPublisher.sink { [weak self] cartMenuItemId in
            print("delete item")
        }
        .store(in: &subscriptions)
        tableView.changeOptionPublisher.sink { [weak self] cartMenuItemId in
            print("change opotion")
        }
        .store(in: &subscriptions)
        
        tableView.emptyCartPublisher.sink { [weak self] in
            self?.emptyCart()
        }
        .store(in: &subscriptions)
        
        // MARK: - bottomSheet
        bottomSheet.bottomSheetButtonTappedPublisher.sink { [weak self] in
            self?.orderButtonTapped()
        }
        .store(in: &subscriptions)
        
        // MARK: - Empty View
        emptyView.addMenuButtonTappedPublisher.sink { [weak self] in
            self?.popToOrderTabbarViewController()
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
        let resetCartPopUpView = OrderCartPopUpView()
        resetCartPopUpView.configure(message: "영업시간이 아니라서 주문할 수 없어요.\n담았던 메뉴는 삭제할까요?", leftButtonText: "아니오", rightButtonText: "예", emptyCart: emptyCart)
        resetCartPopUpView.frame = window.bounds
        window.addSubview(resetCartPopUpView)
    }
}

extension OrderCartViewController {
    
    private func orderButtonTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let resetCartPopUpView = OrderCartPopUpView()
        resetCartPopUpView.configure(message: "영업시간이 아니라서 주문할 수 없어요.\n담았던 메뉴는 삭제할까요?", leftButtonText: "아니오", rightButtonText: "예", emptyCart: emptyCart)
        resetCartPopUpView.frame = window.bounds
        window.addSubview(resetCartPopUpView)
    }
    
    private func emptyCart() {
        tableView.isHidden = true
        emptyView.isHidden = false
        bottomSheet.isHidden = true
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
        [emptyView, tableView, bottomSheet].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        bottomSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIApplication.hasHomeButton() ? 72 : 106)
        }
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomSheet.snp.top)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .appColor(.newBackground)
        setUpLayouts()
        setUpConstraints()
    }
}
