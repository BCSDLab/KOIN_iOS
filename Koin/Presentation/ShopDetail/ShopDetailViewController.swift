//
//  ShopDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import UIKit
import Combine

final class ShopDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopDetailViewModel
    private let isFromOrder: Bool
    private let inputSubject = PassthroughSubject<ShopDetailViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private var isAddingMenuAvailable: Bool = true
    private var navigationBarStyle: NavigationBarStyle = .orderTransparent
    
    // MARK: - Components
    private let tableHeaderView = ShopDetailTableViewTableHeaderView()
    private let navigationBarLikeView = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
        $0.layer.opacity = 0
    }
    private let menuGroupNameCollectionViewSticky = ShopDetailMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 4
        $0.scrollDirection = .horizontal
    }).then {
        $0.backgroundColor = .appColor(.newBackground)
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsHorizontalScrollIndicator = false
        $0.layer.masksToBounds = false
        $0.isHidden = true
        $0.allowsMultipleSelection = false
        $0.layer.masksToBounds = false
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.08, x: 0, y: 4, blur: 10, spread: 0)
    }
    private let menuGroupTableView = ShopDetailTableView(frame: .zero, style: .grouped).then {
        $0.contentInsetAdjustmentBehavior = .never
        $0.backgroundColor = .clear
        $0.sectionFooterHeight = .zero
        $0.separatorStyle = .none
        $0.sectionHeaderHeight = 56
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 112
    }
    private let bottomSheet = ShopDetailBottomSheet().then {
        $0.isHidden = true
    }
    private let popUpView = ShopDetailPopUpView().then {
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init(viewModel: ShopDetailViewModel, isFromOrder: Bool) {
        self.viewModel = viewModel
        self.isFromOrder = isFromOrder
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        view.backgroundColor = UIColor.appColor(.newBackground)
        bind()
        inputSubject.send(.viewDidLoad)
        configureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar(style: navigationBarStyle)
        configureRightBarButton()
        inputSubject.send(.viewWillAppear)
        menuGroupTableView.configure(navigationBarHeight: navigationController?.navigationBar.frame.height ?? 0)
    }
}

extension ShopDetailViewController {
    
    // MARK: - bind
    private func bind() {
        // viewModel
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { [weak self] output in
            switch output {
            // 기본정보 - tableHeaderView
            case .updateInfoView(let orderShopSummary, let isFromOrder):
                self?.tableHeaderView.updateInfoView(orderShopSummary: orderShopSummary, isFromOrder: isFromOrder)
            case .updateMenusGroups(let orderShopMenusGroups):
                self?.tableHeaderView.updateMenusGroups(orderShopMenusGroups: orderShopMenusGroups)
                self?.menuGroupNameCollectionViewSticky.configure(menuGroup: orderShopMenusGroups.menuGroups)
            case let .updateIsAvailables(delivery, takeOut, payBank, payCard):
                self?.tableHeaderView.updateIsAvailables(delivery: delivery, takeOut: takeOut, payBank: payBank, payCard: payCard)
                
            // 기본정보 - tableView
            case .updateMenus(let orderShopMenus):
                self?.menuGroupTableView.configure(orderShopMenus)
            // 장바구니
            case let .updateBottomSheet(cartSummary):
                self?.bottomSheet.isHidden = !cartSummary.isAvailable
                self?.bottomSheet.configure(cartSummary: cartSummary)
                self?.updateTableViewConstraint(shouldShowBottomSheet: cartSummary.isAvailable)
            case let .updateIsAddingMenuAvailable(isAddingMenuAvailable):
                self?.isAddingMenuAvailable = isAddingMenuAvailable
            case let .updateCartItemsCount(count):
                self?.bottomSheet.configure(count: count)
                if count == 0 {
                    self?.isAddingMenuAvailable = true
                }
            }
        }
        .store(in: &subscriptions)
        
        // MARK: - TableHeaderView
        tableHeaderView.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionViewSticky.contentOffset = contentOffset
            }
            .store(in: &subscriptions)
        
        tableHeaderView.didSelectCellPublisher.sink { [weak self] indexPath in
            guard let self = self else { return }
            let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
            self.menuGroupTableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)
            self.menuGroupNameCollectionViewSticky.configure(selectedIndexPath: indexPath)
            self.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
            .store(in: &subscriptions)
        tableHeaderView.shouldSetContentInsetPublisher.sink { [weak self] shouldSetContentInset in
            let topInset = UIApplication.topSafeAreaHeight() + (self?.navigationController?.navigationBar.frame.height ?? 0) + (self?.menuGroupNameCollectionViewSticky.frame.height ?? 0) - 3
            self?.menuGroupTableView.contentInset = UIEdgeInsets(top: shouldSetContentInset ? topInset : 0, left: 0, bottom: 0, right: 0)
            }
            .store(in: &subscriptions)
        
        // MARK: - GroupNameCollectionView
        menuGroupNameCollectionViewSticky.didScrollPublisher.sink { [weak self] contentOffset in
            self?.tableHeaderView.update(contentOffset: contentOffset)
            }
            .store(in: &subscriptions)
        menuGroupNameCollectionViewSticky.didSelectCellPublisher
            .sink { [weak self] indexPath in
                guard let self = self else { return }
                let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
                self.menuGroupTableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)
                self.menuGroupNameCollectionViewSticky.configure(selectedIndexPath: indexPath)
                self.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.tableHeaderView.selectItem(at: indexPath)
                
            }
            .store(in: &subscriptions)
        
        // MARK: - tableView
        menuGroupTableView.didTapCellPublisher
            .sink { [weak self] menuId in
                guard let self = self, self.isFromOrder else { return } // Shop에서 왔으면 종료
                if isAddingMenuAvailable {
                    // 다음 화면 (메뉴 상세페이지) 로 넘어가는 로직 // 담을 수 있으면 게속
                    navigateToMenuDetail(menuId: menuId)
                }
                else {
                    showPopUpView(menuId: menuId) // 담을 수 없으면 팝업
                }
            }
            .store(in: &subscriptions)
        
        menuGroupTableView.shouldSetNavigationBarTransparentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTransparent in
                self?.navigationBarStyle = isTransparent ? .order : .orderTransparent
                UIView.animate(withDuration: 0.25) {
                    self?.configureNavigationBar(style: isTransparent ? .order : .orderTransparent)
                }
            }
            .store(in: &subscriptions)
        menuGroupTableView.navigationBarOpacityPublisher
            .sink { [weak self] opacity in
                self?.navigationBarLikeView.layer.opacity = opacity
            }
            .store(in: &subscriptions)
        menuGroupTableView.shouldShowStickyPublisher
            .sink { [weak self] shouldShowSticky in
                self?.menuGroupNameCollectionViewSticky.isHidden = !shouldShowSticky
            }
            .store(in: &subscriptions)
        menuGroupTableView.shouldSetContentInsetPublisher
            .sink { [weak self] shouldSetContentInset in
                let topInset = UIApplication.topSafeAreaHeight() + (self?.navigationController?.navigationBar.frame.height ?? 0) + (self?.menuGroupNameCollectionViewSticky.frame.height ?? 0) - 3
                self?.menuGroupTableView.contentInset = UIEdgeInsets(top: shouldSetContentInset ? topInset : 0, left: 0, bottom: 0, right: 0)
            }
            .store(in: &subscriptions)
        
        // MARK: - PopUpView
        popUpView.leftButtonTappedPublisher
            .sink { [weak self] in
                self?.hidePopUpView()
            }
            .store(in: &subscriptions)
        
        popUpView.rightButtonTappedPublisher
            .sink { [weak self] menuId in
                self?.hidePopUpView()
                self?.inputSubject.send(.resetCart)
                self?.navigateToMenuDetail(menuId: menuId)// 메뉴 상세페이지로 넘어가기
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - shouldShowBottomSheet
    private func updateTableViewConstraint(shouldShowBottomSheet: Bool) {
        menuGroupTableView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(shouldShowBottomSheet ? (UIApplication.hasHomeButton() ? -72 : -106 ) : 0)
        }
    }

    // MARK: - Navigation Right Bar Button
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: .shoppingCartWhite)?.resize(to: CGSize(width: 24, height: 24)),
            style: .plain,
            target: self,
            action: #selector(didTapCart)
        )
    }
    
    // MARK: - @objc
    @objc private func navigationButtonTapped() {
        navigationController?.pushViewController(UIViewController(), animated: true)
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
    // MARK: - show/hide popUpView
    private func showPopUpView(menuId: Int) {
        navigationController?.navigationBar.isHidden = true
        popUpView.configure(menuId: menuId)
        popUpView.isHidden = false
    }
    private func hidePopUpView() {
        navigationController?.navigationBar.isHidden = false
        popUpView.isHidden = true
    }
    // MARK: - navigate to menu detail
    private func navigateToMenuDetail(menuId: Int) {
        print("다음화면으로!")
    }
}

extension ShopDetailViewController {
    // MARK: - ConfigureView
    private func setUpConstraints() {
        menuGroupTableView.snp.makeConstraints {
            //$0.top.equalToSuperview().offset(UIApplication.topSafeAreaHeight() + (navigationController?.navigationBar.frame.height ?? 0) + 66 )
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        bottomSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIApplication.hasHomeButton() ? 72 : 106)
        }
        menuGroupNameCollectionViewSticky.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationBarLikeView.snp.bottom)
            $0.height.equalTo(66)
        }
        navigationBarLikeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIApplication.topSafeAreaHeight() + (navigationController?.navigationBar.frame.height ?? 0))
        }
        popUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func setUpLayout() {
        [menuGroupTableView, bottomSheet, menuGroupNameCollectionViewSticky, navigationBarLikeView, popUpView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configurePopUpView() {
        popUpView.configure(message: "장바구니에는 같은 가게 메뉴만\n담을 수 있어요. \n담았던 메뉴는 삭제할까요?",
                            leftButtonText: "아니오",
                            rightButtonText: "예")
    }
    
    private func setTableHeaderView() {
        menuGroupTableView.tableHeaderView = tableHeaderView
    }
    
    private func configureView(){
        configurePopUpView()
        setTableHeaderView()
        setUpLayout()
        setUpConstraints()
    }
}
