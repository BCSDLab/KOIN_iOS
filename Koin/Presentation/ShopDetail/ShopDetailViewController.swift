//
//  ShopDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import UIKit
import Combine

class ShopDetailViewController: UIViewController {
    
    // MARK: - Properties
    let viewModel: ShopDetailViewModel
    private let inputSubject = PassthroughSubject<ShopDetailViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let shopId: Int?
    private let isFromOrder: Bool
    
    private var shouldShowSticky: Bool = false
    private var isNavigationBarOpaque: Bool = false
    
    
    // MARK: - Components
    let scrollView = UIScrollView().then {
        $0.contentInsetAdjustmentBehavior = .never
    }
    let contentView = UIView()
    let imagesCollectionView = ShopDetailImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/1.21)
        $0.minimumLineSpacing = 0
    })
    let imagesPageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = UIColor.appColor(.neutral0)
        $0.pageIndicatorTintColor = UIColor.appColor(.neutral400)
    }
    let infoView = ShopDetailInfoView()
    let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    let menuGroupNameCollectionView = ShopDetailMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 4
        $0.scrollDirection = .horizontal
    }).then {
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsHorizontalScrollIndicator = false
        $0.layer.masksToBounds = false
        $0.allowsMultipleSelection = false
    }
    let menuGroupNameCollectionViewSticky = ShopDetailMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
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
    let menuGroupTableView = ShopDetailMenuGroupTableView(frame: .zero, style: .grouped).then {
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
        $0.sectionHeaderTopPadding = .zero
        $0.sectionFooterHeight = .zero
        $0.separatorStyle = .none
    }
    let bottomSheet = ShopDetailBottomSheet()
    let navigationBarLikeView = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
        $0.layer.opacity = 0
    }
    
    // MARK: - Initializer
    init(viewModel: ShopDetailViewModel, shopId: Int?, isFromOrder: Bool) {
        self.viewModel = viewModel
        self.shopId = shopId
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
    }
}

extension ShopDetailViewController {
    
    // MARK: - bind
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { [weak self] output in
            switch output {
            case .updateInfoView(let orderShopSummary):
                self?.imagesCollectionView.bind(orderImage: orderShopSummary.images)
                self?.imagesPageControl.numberOfPages = orderShopSummary.images.count
                self?.infoView.bind(orderShopSummary: orderShopSummary)
            case .updateMenusGroups(let orderShopMenusGroups):
                self?.menuGroupNameCollectionView.bind(menuGroup: orderShopMenusGroups.menuGroups)
                self?.menuGroupNameCollectionViewSticky.bind(menuGroup: orderShopMenusGroups.menuGroups)
            case .updateMenus(let orderShopMenus):
                self?.menuGroupTableView.bind(orderShopMenus)
                self?.updateTableViewHeight(orderShopMenus)
            }
        }
        .store(in: &subscriptions)
        
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
        
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
    }
    
    // MARK: - configureRightBarButton
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.appImage(asset: .shoppingCartWhite)?.resize(to: CGSize(width: 24, height: 24)), style: .plain, target: self, action: #selector(navigationButtonTapped))
    }
    
    // MARK: - updateTableViewHeight
    private func updateTableViewHeight(_ orderShopMenus: [OrderShopMenus]) {
        menuGroupTableView.snp.makeConstraints {
            $0.height.equalTo(tableViewHeight(orderShopMenus))
        }
    }
    
    // MARK: - ConfigureView
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)//34)
        }
        menuGroupTableView.snp.makeConstraints {
            $0.top.equalTo(menuGroupNameCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset( -20 + (UIApplication.hasHomeButton() ? -72 : -106 ))
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
    }
    private func setUpLayout() {
        [scrollView, bottomSheet, menuGroupNameCollectionViewSticky, navigationBarLikeView].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [imagesCollectionView, imagesPageControl, infoView, separatorView, menuGroupNameCollectionView, menuGroupTableView].forEach {
            contentView.addSubview( $0 )
        }
    }
    private func configureView(){
        setUpLayout()
        setUpConstraints()
        
        if(!isFromOrder) {
            bottomSheet.isHidden = true
        }
    }
    private func setDelegate() {
        scrollView.delegate = self
    }
    
    // MARK: - @objc
    @objc private func navigationButtonTapped() {
        navigationController?.pushViewController(UIViewController(), animated: true)
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
