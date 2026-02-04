//
//  ShopSummaryViewController.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import UIKit
import Combine

final class ShopSummaryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopSummaryViewModel
    private let inputSubject = PassthroughSubject<ShopSummaryViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer().then {
        $0.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.03).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        $0.locations = [0.0, 0.9, 1.0]
        $0.startPoint = CGPoint(x: 0.0, y: 0.0)
        $0.endPoint = CGPoint(x: 0.0, y: 1.0)
    }

    private let tableHeaderView = ShopSummaryTableViewTableHeaderView()
    
    private let menuGroupNameCollectionViewSticky = ShopSummaryMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
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
    
    private let menuGroupTableView = ShopSummaryTableView(frame: .zero, style: .grouped).then {
        $0.contentInsetAdjustmentBehavior = .never
        $0.backgroundColor = .clear
        $0.sectionFooterHeight = .zero
        $0.separatorStyle = .none
        $0.sectionHeaderHeight = 56
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 112
    }
    
    private let popUpView = ShopSummaryPopUpView().then {
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init(viewModel: ShopSummaryViewModel) {
        self.viewModel = viewModel
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
        configureNavigationBar()
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopDetailViewBack))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCall))
    }
    
    
    //FIXME: - API가 로딩되기전에 뒤로가기시 Value가 알 수 없음으로 찍힘
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.isMovingFromParent || self.isBeingDismissed else { return }
        let shopName = self.viewModel.shopName
        let currentPage = self.viewModel.backCategoryName
        let isSwipe = navigationController?.transitionCoordinator?.isInteractive ?? false
        let eventCategory: EventParameter.EventCategory = isSwipe ? .swipe : .click
        
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopDetailViewBack))
        if currentPage != nil {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopDetailViewBack, eventCategory, shopName, nil, currentPage, nil, .shopDetailViewBack))
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (viewModel.opacity == 1 ? .darkContent : .lightContent)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
        menuGroupTableView.configure(safeAreaHeight: gradientView.frame.height)
    }
}

extension ShopSummaryViewController {
    
    // MARK: - bind
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .update1(images, name, rating, reviewCount):
                self.viewModel.cachedImages = images
                self.tableHeaderView.configure1(
                    images: images,
                    name: name,
                    rating: rating,
                    reviewCount: reviewCount
                )
                break
            case let .update2(delivery, payBank, payCard, maxDeliveryTip, description, phonenumber):
                self.tableHeaderView.configure2(
                    delivery: delivery,
                    payBank: payBank,
                    payCard: payCard,
                    maxDeliveryTip: maxDeliveryTip,
                    description: description,
                    phonenumber: phonenumber)
            case let .update3(menusGroups, menus):
                self.tableHeaderView.configure3(orderShopMenusGroups: menusGroups)
                self.menuGroupNameCollectionViewSticky.configure(menuGroup: menusGroups.menuGroups)
                self.menuGroupTableView.configure(menus)
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
        
        tableHeaderView.reviewButtonTappedPublisher
            .sink { [weak self] in
                self?.navigateToReviewListViewController()
            }
            .store(in: &subscriptions)
        
        tableHeaderView.navigateToShopInfoPublisher.sink { [weak self] shouldHighlight in
            guard let self else { return }
            self.inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopDetailViewInfo, .click, self.viewModel.shopName))
            let shopService = DefaultShopService()
            let shopRepository = DefaultShopRepository(service: shopService)
            let fetchOrderShopDetailFromShopUseCase = DefaultFetchOrderShopDetailFromShopUseCase(repository: shopRepository)
            let viewModel = ShopDetailViewModel(fetchOrderShopDetailFromShopUseCase: fetchOrderShopDetailFromShopUseCase,
                                                shopId: self.viewModel.shopId)
            let viewController = ShopDetailViewController(viewModel: viewModel, shouldHighlight: shouldHighlight)
            viewController.title = "가게정보"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        .store(in: &subscriptions)
        
        tableHeaderView.phoneButtonTappedPublisher.sink { [weak self] in
            self?.makePhonecall()
            
            guard let self else { return }
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCall))
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCall, EventParameter.EventCategory.click, self.viewModel.shopName, nil, nil, nil, EventParameter.EventLabelNeededDuration.shopCall))
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
        menuGroupTableView.updateNavigationBarPublisher
            .sink { [weak self] navigationBarItemColor, opacity in
                self?.viewModel.navigationBarItemColor = navigationBarItemColor
                self?.viewModel.opacity = opacity
                self?.configureNavigationBar()
            }.store(in: &subscriptions)
        
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
        
        menuGroupTableView.didEndScrollPublisher
            .sink { [ weak self ] in
                guard let self else { return }
                self.inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopDetailView, .scroll, self.viewModel.shopName))
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
                self?.navigateToMenuDetail(menuId: menuId)
            }
            .store(in: &subscriptions)
        
        // MARK: - ThumbnailImage
        tableHeaderView.didTapThumbnailPublisher
            .sink { [weak self] indexPath in
                guard let self,
                      0 < self.viewModel.cachedImages.count,
                      self.viewModel.cachedImages.first?.imageUrl != nil else { return }
                
                let zoomedViewController = ZoomedImageViewControllerB()
                zoomedViewController.configure(urls: viewModel.cachedImages.map { return $0.imageUrl },
                                               initialIndexPath: indexPath)
                self.present(zoomedViewController, animated: true)
            }.store(in: &subscriptions)
    }
    
    private func configureNavigationBar() {
        setNeedsStatusBarAppearanceUpdate()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.appColor(.newBackground).withAlphaComponent(viewModel.opacity)
        appearance.titleTextAttributes.updateValue(viewModel.navigationBarItemColor.withAlphaComponent(viewModel.opacity), forKey: .foregroundColor)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = viewModel.navigationBarItemColor
    }
    
    // MARK: - shouldShowBottomSheet
    private func updateTableViewConstraint(shouldShowBottomSheet: Bool) {
        menuGroupTableView.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(shouldShowBottomSheet ? (UIApplication.hasHomeButton() ? -72 : -106 ) : 0)
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
    
    // MARK: - Navigation
    private func navigateToReviewListViewController() {
        let reviewListViewController = ReviewListViewController(shopId: viewModel.shopId, shopName: viewModel.shopName)
        reviewListViewController.title = "리뷰"
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopDetailViewReview, .click, viewModel.shopName))
        navigationController?.pushViewController(reviewListViewController, animated: true)
    }
}

extension ShopSummaryViewController {
    
    private func makePhonecall() {
        if let phoneUrl = URL(string: "tel://" + self.viewModel.phonenumber.replacingOccurrences(of: "-", with: "")),
           UIApplication.shared.canOpenURL(phoneUrl){
            print("open")
            UIApplication.shared.open(phoneUrl)
        }
        else {
            print("parsing error")
        }
    }
}

extension ShopSummaryViewController {
    // MARK: - ConfigureView
    private func setUpConstraints() {
        gradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        menuGroupTableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        menuGroupNameCollectionViewSticky.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(66)
        }
        
        popUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setUpLayout() {
        [menuGroupTableView, gradientView, menuGroupNameCollectionViewSticky, popUpView].forEach {
            view.addSubview($0)
        }
        
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    private func setTableHeaderView() {
        menuGroupTableView.tableHeaderView = tableHeaderView
    }
    
    private func configureView(){
        setTableHeaderView()
        setUpLayout()
        setUpConstraints()
        navigationItem.backButtonTitle = ""
    }
}
