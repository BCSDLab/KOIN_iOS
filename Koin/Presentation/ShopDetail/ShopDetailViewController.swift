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
    
    private var shouldShowSticky: Bool = false
    private var isNavigationBarOpaque: Bool = false
    private var isAddingMenuAvailable: Bool = false
    
    // MARK: - Components
    private let scrollView = UIScrollView().then {
        $0.contentInsetAdjustmentBehavior = .never
    }
    private let contentView = UIView()
    private let imagesCollectionView = ShopDetailImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.21)
        $0.minimumLineSpacing = 0
    }).then {
        $0.showsHorizontalScrollIndicator = false
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
    private let menuGroupTableView = ShopDetailMenuGroupTableView(frame: .zero, style: .grouped).then {
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.sectionHeaderTopPadding = .zero
        $0.sectionFooterHeight = .zero
        $0.separatorStyle = .none
    }
    private let bottomSheet = ShopDetailBottomSheet().then {
        $0.isHidden = true
    }
    private let navigationBarLikeView = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
        $0.layer.opacity = 0
    }
    private let cartItemsCountLabel = UILabel().then {
        $0.backgroundColor = .appColor(.new500)
        $0.textColor = .appColor(.neutral0)
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.contentMode = .center
        $0.textAlignment = .center
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
        setDelegate()
    }
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar(style: .orderTransparent)
        configureRightBarButton()
        inputSubject.send(.viewWillAppear)
    }
}

extension ShopDetailViewController {
    
    // MARK: - bind
    private func bind() {
        // viewModel
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { [weak self] output in
            switch output {
            case .updateInfoView(let orderShopSummary, let isFromOrder):
                self?.imagesCollectionView.configure(orderImage: orderShopSummary.images)
                self?.imagesPageControl.numberOfPages = orderShopSummary.images.count
                self?.infoView.configure(orderShopSummary: orderShopSummary, isFromOrder: isFromOrder)
            case .updateMenusGroups(let orderShopMenusGroups):
                self?.menuGroupNameCollectionView.configure(menuGroup: orderShopMenusGroups.menuGroups)
                self?.menuGroupNameCollectionViewSticky.configure(menuGroup: orderShopMenusGroups.menuGroups)
            case .updateMenus(let orderShopMenus):
                self?.menuGroupTableView.configure(orderShopMenus)
                self?.updateTableViewHeight(orderShopMenus)
            case let .updateIsAvailables(delivery, takeOut, payBank, payCard):
                self?.infoView.configure(isDelieveryAvailable: delivery, isTakeoutAvailable: takeOut, payCard: payCard, payBank: payBank)
            case let .updateBottomSheet(cartSummary):
                self?.bottomSheet.isHidden = !cartSummary.isAvailable
                self?.bottomSheet.configure(cartSummary: cartSummary)
                self?.updateBottomSheetConstraint(shouldShowBottomSheet: cartSummary.isAvailable)
            case let .updateIsAddingMenuAvailable(isAddingMenuAvailable):
                self?.isAddingMenuAvailable = isAddingMenuAvailable
            case let .updateCartItemsCount(count):
                self?.updateCartItemsCountLabel(count: count)
                self?.bottomSheet.configure(count: count)
                if count == 0 {
                    self?.isAddingMenuAvailable = true
                }
            }
        }
        .store(in: &subscriptions)
        
        // tableView
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
        
        // popUpView
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
        
        // imagesCollectionView
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
        
        // menuGroupCollectionView
        menuGroupNameCollectionView.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionView.contentOffset = contentOffset
            self?.menuGroupNameCollectionViewSticky.contentOffset = contentOffset
        }
        .store(in: &subscriptions)
        
        menuGroupNameCollectionViewSticky.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionView.contentOffset = contentOffset
            self?.menuGroupNameCollectionViewSticky.contentOffset = contentOffset
        }
        .store(in: &subscriptions)
        
        menuGroupNameCollectionView.didSelectCellPublisher.sink { [weak self] indexPath in
            self?.menuGroupNameCollectionViewSticky.indexPathsForSelectedItems?.forEach {
                self?.menuGroupNameCollectionViewSticky.configureDeselectedCell($0)
            }
            self?.menuGroupNameCollectionViewSticky.configureSelectedCell(indexPath)
            self?.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self?.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            
            let section = indexPath.row
            let defaultCGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            let height =
                UIScreen.main.bounds.height
                - UIApplication.topSafeAreaHeight()
                - (self?.navigationController?.navigationBar.bounds.height ?? 0)
                - (self?.menuGroupNameCollectionView.bounds.height ?? 0)

            guard let sectionHeaderViewMinY = self?.menuGroupTableView.headerView(forSection: section)?.convert(self?.menuGroupTableView.bounds ?? defaultCGRect, to: self?.contentView).minY,
                  let contentViewMaxY = self?.contentView.convert(self?.contentView.bounds ?? defaultCGRect, to: self?.view).maxY,
                  let bottomSheetMinY = self?.bottomSheet.convert(self?.bottomSheet.bounds ?? defaultCGRect, to: self?.view).minY else {
                return
            }
            if ( sectionHeaderViewMinY + height < contentViewMaxY) { // 스크롤 범위를 벗어나지 않는 경우
                let rect = CGRect(x: 0, y: sectionHeaderViewMinY, width: 1, height: height)
                self?.scrollView.scrollRectToVisible(rect, animated: true)
            }
            else { // 스크롤 범위를 벗어나는 경우
                let rect = CGRect(x: 0, y: contentViewMaxY, width: 1, height: 1)
                self?.scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
        .store(in: &subscriptions)
        
        menuGroupNameCollectionViewSticky.didSelectCellPublisher.sink { [weak self] indexPath in
            self?.menuGroupNameCollectionView.indexPathsForSelectedItems?.forEach {
                self?.menuGroupNameCollectionView.configureDeselectedCell($0)
            }
            self?.menuGroupNameCollectionView.configureSelectedCell(indexPath)
            self?.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self?.menuGroupNameCollectionViewSticky.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
         
            let section = indexPath.row
            let defaultCGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            let height =
                UIScreen.main.bounds.height
                - UIApplication.topSafeAreaHeight()
                - (self?.navigationController?.navigationBar.bounds.height ?? 0)
                - (self?.menuGroupNameCollectionView.bounds.height ?? 0)

            guard let sectionHeaderViewMinY = self?.menuGroupTableView.headerView(forSection: section)?.convert(self?.menuGroupTableView.bounds ?? defaultCGRect, to: self?.contentView).minY,
                  let contentViewMaxY = self?.contentView.convert(self?.contentView.bounds ?? defaultCGRect, to: self?.view).maxY,
                  let bottomSheetMinY = self?.bottomSheet.convert(self?.bottomSheet.bounds ?? defaultCGRect, to: self?.view).minY else {
                return
            }
            if ( sectionHeaderViewMinY + height < contentViewMaxY) { // 스크롤 범위를 벗어나지 않는 경우
                let rect = CGRect(x: 0, y: sectionHeaderViewMinY, width: 1, height: height)
                self?.scrollView.scrollRectToVisible(rect, animated: true)
            }
            else { // 스크롤 범위를 벗어나는 경우
                let rect = CGRect(x: 0, y: contentViewMaxY, width: 1, height: 1)
                self?.scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - continue adding menu
    private func continueAddingMenu(menuId: Int) {
        self.navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
    // MARK: - shouldShowBottomSheet
    private func updateBottomSheetConstraint(shouldShowBottomSheet: Bool) {
        scrollView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(shouldShowBottomSheet ? (UIApplication.hasHomeButton() ? -72 : -106 ) : 0)
        }
    }
    
    // MARK: - CartItemsCount
    private func updateCartItemsCountLabel(count: Int) {
        if count == 0 {
            cartItemsCountLabel.isHidden = true
            return
        }
        cartItemsCountLabel.isHidden = false
        cartItemsCountLabel.text = "\(count)"
    }

    // MARK: - Navigation Right Bar Button
    private func configureRightBarButton() {
        let cartImage = UIImage.appImage(asset: .shoppingCart)?
            .withRenderingMode(.alwaysTemplate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: .shoppingCartWhite)?.resize(to: CGSize(width: 24, height: 24)),
            style: .plain,
            target: self,
            action: #selector(didTapCart)
        )
        
        // TODO: CartItemsCount를 rightButton에 어떻게 붙일까 ㅠ
    }
    
    // MARK: - updateTableViewHeight
    private func updateTableViewHeight(_ orderShopMenus: [OrderShopMenus]) {
        menuGroupTableView.snp.makeConstraints {
            $0.height.equalTo(tableViewHeight(orderShopMenus))
        }
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

extension ShopDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let naviBottom = navigationController?.navigationBar.frame.maxY ?? 0
        let imagesBottom = imagesCollectionView.convert(imagesCollectionView.bounds, to: view).maxY
        let collectionViewTop = menuGroupNameCollectionView.convert(menuGroupNameCollectionView.bounds, to: view).minY
        
        let shouldShowSticky = collectionViewTop < naviBottom
        let isNavigationBarOpaque = imagesBottom < naviBottom
        let opacity = 1 - (imagesBottom - naviBottom)/100
        
        if shouldShowSticky != self.shouldShowSticky {
            self.shouldShowSticky = shouldShowSticky
            menuGroupNameCollectionViewSticky.isHidden = !shouldShowSticky
        }
        if isNavigationBarOpaque != self.isNavigationBarOpaque {
            self.isNavigationBarOpaque = isNavigationBarOpaque
            if (isNavigationBarOpaque) {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.configureNavigationBar(style: .order)
                })
            }
            else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.configureNavigationBar(style: .orderTransparent)
                })
            }
        }
        navigationBarLikeView.layer.opacity = Float(opacity)
    }
}

extension ShopDetailViewController {
    
    // MARK: - helper
    private func tableViewHeight(_ orderShopMenus: [OrderShopMenus]) -> Int {
        let groupNameHeight = 56
        let minimumRowHeight = 112
        let nameHeight = 29
        let descriptionHeight = 19
        let priceHeight = 22
        let priceTopPadding = 4
        let insetHeight = 24
        
        var tableViewHeight = 0
        orderShopMenus.forEach {
            var sectionHeight = 0
            sectionHeight += groupNameHeight
            $0.menus.forEach {
                var rowHeight = 0
                rowHeight += nameHeight
                rowHeight += $0.description != nil ? descriptionHeight : 0
                rowHeight += 1 < $0.prices.count ? priceTopPadding : 0
                rowHeight += $0.prices.count * priceHeight
                rowHeight += insetHeight
                sectionHeight += rowHeight > minimumRowHeight ? rowHeight : minimumRowHeight
            }
            tableViewHeight += sectionHeight
        }
        return tableViewHeight
    }
}

extension ShopDetailViewController {
    // MARK: - ConfigureView
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        imagesCollectionView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
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
            $0.top.equalTo(infoView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(8)
        }
        menuGroupNameCollectionView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        menuGroupTableView.snp.makeConstraints {
            $0.top.equalTo(menuGroupNameCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-20)
        }
        bottomSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIApplication.hasHomeButton() ? 72 : 106)
        }
        menuGroupNameCollectionViewSticky.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(66)
        }
        navigationBarLikeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(
                UIApplication.topSafeAreaHeight()
                + (navigationController?.navigationBar.bounds.height ?? 0)
            )
        }
        popUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func setUpLayout() {
        [scrollView, bottomSheet, menuGroupNameCollectionViewSticky, navigationBarLikeView, popUpView].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [imagesCollectionView, imagesPageControl, infoView, separatorView, menuGroupNameCollectionView, menuGroupTableView].forEach {
            contentView.addSubview( $0 )
        }
    }
    
    private func configurePopUpView() {
        popUpView.configure(message: "장바구니에는 같은 가게 메뉴만\n담을 수 있어요. \n담았던 메뉴는 삭제할까요?",
                            leftButtonText: "아니오",
                            rightButtonText: "예")
    }
    
    private func configureView(){
        configurePopUpView()
        setUpLayout()
        setUpConstraints()
    }
    
    // MARK: - SetDelegate
    private func setDelegate() {
        scrollView.delegate = self
    }
}
