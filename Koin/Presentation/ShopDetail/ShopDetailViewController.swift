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
    
    // MARK: - Components
    private let imagesCollectionView = ShopDetailImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.21)
        $0.minimumLineSpacing = 0
    }).then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    private let imagesPageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = UIColor.appColor(.neutral0)
        $0.pageIndicatorTintColor = UIColor.appColor(.neutral400)
    }
    private let infoView = ShopDetailInfoView()
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    private let menuGroupNameCollectionView = ShopDetailMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 4
        $0.scrollDirection = .horizontal
    }).then {
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsHorizontalScrollIndicator = false
        $0.layer.masksToBounds = false
        $0.allowsMultipleSelection = false
    }
    
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
        configureNavigationBar(style: .orderTransparent)
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
                self?.imagesCollectionView.configure(orderImage: orderShopSummary.images)
                self?.imagesPageControl.numberOfPages = orderShopSummary.images.count
                self?.infoView.configure(orderShopSummary: orderShopSummary, isFromOrder: isFromOrder)
            case .updateMenusGroups(let orderShopMenusGroups):
                self?.menuGroupNameCollectionView.configure(menuGroup: orderShopMenusGroups.menuGroups)
                self?.menuGroupNameCollectionViewSticky.configure(menuGroup: orderShopMenusGroups.menuGroups)
            case let .updateIsAvailables(delivery, takeOut, payBank, payCard):
                self?.infoView.configure(isDelieveryAvailable: delivery, isTakeoutAvailable: takeOut,
                                   payCard: payCard, payBank: payBank)
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
        
        // MARK: - ImagesCollectionView
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
        
        // MARK: - GroupNameCollectionView
        menuGroupNameCollectionView.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionViewSticky.contentOffset = contentOffset
            }
            .store(in: &subscriptions)
        menuGroupNameCollectionViewSticky.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionView.contentOffset = contentOffset
            }
            .store(in: &subscriptions)
        
        menuGroupNameCollectionView.didSelectCellPublisher
            .sink { [weak self] indexPath in
                guard let self = self else { return }
                let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
                self.menuGroupTableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)
                self.menuGroupNameCollectionView.configure(selectedIndexPath: indexPath)
                self.menuGroupNameCollectionViewSticky.configure(selectedIndexPath: indexPath)
                self.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
            .store(in: &subscriptions)
        menuGroupNameCollectionViewSticky.didSelectCellPublisher
            .sink { [weak self] indexPath in
                guard let self = self else { return }
                let tableViewIndexPath = IndexPath(row: 0, section: indexPath.row)
                self.menuGroupTableView.scrollToRow(at: tableViewIndexPath, at: .top, animated: true)
                self.menuGroupNameCollectionView.configure(selectedIndexPath: indexPath)
                self.menuGroupNameCollectionViewSticky.configure(selectedIndexPath: indexPath)
                self.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
            .store(in: &subscriptions)
        
        // MARK: - tableView
        menuGroupTableView.tableViewDidScroll
            .sink { [weak self] contentOffset in
                self?.imagesCollectionView.snp.updateConstraints {
                    $0.top.equalToSuperview().offset(-contentOffset)
                }
            }
            .store(in: &subscriptions)
        
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
        menuGroupTableView.shouldShowSticky
            .sink { [weak self] shouldShowSticky in
                self?.menuGroupNameCollectionViewSticky.isHidden = !shouldShowSticky
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
            let service = DefaultOrderService()
            let repository = DefaultOrderShopRepository(service: service)
            let fetchCartUseCase = DefaultFetchCartUseCase(repository: repository)
            let fetchCartDeliveryUseCase = DefaultFetchCartDeliveryUseCase(repository: repository)
            let fetchCartTakeOutUseCase = DefaultFetchCartTakeOutUseCase(repository: repository)
            let deleteCartMenuItemUseCase = DefaultDeleteCartMenuItemUseCase(repository: repository)
            let viewModel = OrderCartViewModel(fetchCartUseCase: fetchCartUseCase, fetchCartDeliveryUseCase: fetchCartDeliveryUseCase, fetchCartTakeOutUseCase: fetchCartTakeOutUseCase, deleteCartMenuItemUseCase: deleteCartMenuItemUseCase)
            let viewController = OrderCartViewController(viewModel: viewModel)
            viewController.title = "장바구니"
            navigationController?.pushViewController(viewController, animated: true)
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
        imagesCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width / 1.21)
        }
        imagesPageControl.snp.makeConstraints {
            $0.centerX.equalTo(imagesCollectionView)
            $0.bottom.equalTo(imagesCollectionView).offset(-15)
        }
        infoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(imagesCollectionView.snp.bottom)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(infoView.snp.bottom)
            $0.height.equalTo(8)
        }
        menuGroupNameCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(separatorView.snp.bottom)
            $0.height.equalTo(66)
        }
        
        menuGroupTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIApplication.topSafeAreaHeight() + (navigationController?.navigationBar.frame.height ?? 0) + 66 )
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
        [separatorView, menuGroupTableView, imagesCollectionView, imagesPageControl, infoView, menuGroupNameCollectionView, 
         bottomSheet, menuGroupNameCollectionViewSticky, navigationBarLikeView, popUpView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configurePopUpView() {
        popUpView.configure(message: "장바구니에는 같은 가게 메뉴만\n담을 수 있어요. \n담았던 메뉴는 삭제할까요?",
                            leftButtonText: "아니오",
                            rightButtonText: "예")
    }
    
    private func setTableHeaderView() {
        let tableHeaderViewHeight: CGFloat = ( UIScreen.main.bounds.width/1.21 + 212 + 8 + 66 ) - ( UIApplication.topSafeAreaHeight() + (navigationController?.navigationBar.frame.height ?? 0) + 66)
        menuGroupTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: tableHeaderViewHeight))
    }
    
    private func configureView(){
        configurePopUpView()
        setTableHeaderView()
        setUpLayout()
        setUpConstraints()
    }
}
