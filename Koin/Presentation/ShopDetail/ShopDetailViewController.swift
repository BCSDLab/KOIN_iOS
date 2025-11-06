//
//  ShopDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit
import Combine

final class ShopDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopDetailViewModel
    private let shouldHighlight: ShopDetailTableView.HighlightableCell
    private var subscriptions: Set<AnyCancellable> = []
    private let inputSubject = PassthroughSubject<ShopDetailViewModel.Input, Never>()
    
    // MARK: - UI Components
    private let shopDetailTableView: ShopDetailTableView = ShopDetailTableView().then {
        $0.separatorStyle = .none
        $0.allowsSelection = false
    }
    
    // MARK: - Initailizer
    init(viewModel: ShopDetailViewModel, shouldHighlight: ShopDetailTableView.HighlightableCell) {
        self.viewModel = viewModel
        self.shouldHighlight = shouldHighlight
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shopDetailTableView.scrollToHighlightedCell()
    }

    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case .update(let shopDetail):
                self.shopDetailTableView.configure(shopDetail: shopDetail,
                                                   shouldHighlight: self.shouldHighlight,
                                                   isFromOrder: self.viewModel.isFromOrder)
            }
        }
        .store(in: &subscriptions)
    }
    
}

extension ShopDetailViewController {
    
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: .shoppingCartWhite)?.resize(to: CGSize(width: 24, height: 24)),
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
            let service = DefaultOrderService()
            let repository = DefaultOrderShopRepository(service: service)
            let fetchCartUseCase = DefaultFetchCartUseCase(repository: repository)
            let fetchCartDeliveryUseCase = DefaultFetchCartDeliveryUseCase(repository: repository)
            let fetchCartTakeOutUseCase = DefaultFetchCartTakeOutUseCase(repository: repository)
            let deleteCartMenuItemUseCase = DefaultDeleteCartMenuItemUseCase(repository: repository)
            let resetCartUseCase = DefaultResetCartUseCase(repository: repository)
            let viewModel = OrderCartViewModel(fetchCartUseCase: fetchCartUseCase,
                                               fetchCartDeliveryUseCase: fetchCartDeliveryUseCase,
                                               fetchCartTakeOutUseCase: fetchCartTakeOutUseCase,
                                               deleteCartMenuItemUseCase: deleteCartMenuItemUseCase,
                                               resetCartUseCase: resetCartUseCase)
            let viewController = OrderCartViewController(viewModel: viewModel)
            viewController.title = "장바구니"
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension ShopDetailViewController {
    
    private func setUpLayouts() {
        [shopDetailTableView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        shopDetailTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
