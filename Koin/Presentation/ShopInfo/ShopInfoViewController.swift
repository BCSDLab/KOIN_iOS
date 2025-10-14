//
//  ShopInfoViewController.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit
import Combine

final class ShopInfoViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopInfoViewModel
    private let shouldHighlight: ShopInfoTableView.HighlightableCell
    private var subscriptions: Set<AnyCancellable> = []
    let inputSubject = PassthroughSubject<ShopInfoViewModel.Input, Never>()
    
    // MARK: - Components
    private let shopInfoTableView: ShopInfoTableView = ShopInfoTableView().then {
        $0.separatorStyle = .none
        $0.allowsSelection = false
    }
    
    // MARK: - Initailizer
    init(viewModel: ShopInfoViewModel, shouldHighlight: ShopInfoTableView.HighlightableCell) {
        self.viewModel = viewModel
        self.shouldHighlight = shouldHighlight
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        configureNavigationBar(style: .empty)
        configureRightBarButton()
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    override func viewDidAppear(_ animated: Bool) {
        shopInfoTableView.scrollToHighlightedCell()
    }

    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case .update(let shopInfo): self.shopInfoTableView.configure(shopInfo: shopInfo, shouldHighlight: self.shouldHighlight)
            }
        }
        .store(in: &subscriptions)
    }
    
}

extension ShopInfoViewController {
    
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
            let orderCartWebViewController = OrderCartWebViewController()
            orderCartWebViewController.title = "장바구니"
            navigationController?.pushViewController(orderCartWebViewController, animated: true)
        }
    }
}

extension ShopInfoViewController {
    
    private func setUpLayouts() {
        [shopInfoTableView].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        shopInfoTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
