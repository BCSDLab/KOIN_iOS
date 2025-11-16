//
//  ShopSummaryTableViewTableHeaderView.swift
//  koin
//
//  Created by 홍기정 on 10/2/25.
//

import UIKit
import Combine

final class ShopSummaryTableViewTableHeaderView: UIView {
    
    // MARK: - Properties
    let didScrollPublisher = PassthroughSubject<CGPoint, Never>()
    let didSelectCellPublisher = PassthroughSubject<IndexPath, Never>()
    let shouldSetContentInsetPublisher = PassthroughSubject<Bool, Never>()
    let navigateToShopInfoPublisher = PassthroughSubject<ShopDetailTableView.HighlightableCell, Never>()
    let reviewButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let phoneButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let didTapThumbnailPublisher = PassthroughSubject<IndexPath, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let imagesCollectionView = ShopSummaryImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
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
    private let shopSummaryInfoView = ShopSummaryInfoView()
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    private let menuGroupNameCollectionView = ShopSummaryMenuGroupCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumInteritemSpacing = 4
        $0.scrollDirection = .horizontal
    }).then {
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsHorizontalScrollIndicator = false
        $0.layer.masksToBounds = false
        $0.allowsMultipleSelection = false
    }
    
    // MARK: - Initializer
    init() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 1.21 + 212 + 8 + 66 + 56)
        super.init(frame: frame)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    private func bind() {
        // MARK: - ImagesCollectionView
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
        
        imagesCollectionView.didTapThumbnailPublisher.sink { [weak self] indexPath in
            self?.didTapThumbnailPublisher.send(indexPath)
        }.store(in: &subscriptions)
        
        // MARK: - MenuGroupName CollectionView
        menuGroupNameCollectionView.didScrollPublisher.sink { [weak self] contentOffset in
            self?.didScrollPublisher.send(contentOffset)
        }
        .store(in: &subscriptions)
        
        menuGroupNameCollectionView.didSelectCellPublisher.sink { [weak self] indexPath in
            self?.menuGroupNameCollectionView.configure(selectedIndexPath: indexPath)
            self?.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self?.didSelectCellPublisher.send(indexPath)
        }
        .store(in: &subscriptions)
        
        menuGroupNameCollectionView.shouldSetContentInset.sink { [weak self] shouldSetContentInset in
            self?.shouldSetContentInsetPublisher.send(shouldSetContentInset)
        }
        .store(in: &subscriptions)
        
        // MARK: - InfoView
        shopSummaryInfoView.navigateToShopInfoPublisher.sink { [weak self] shouldHighlight in
            self?.navigateToShopInfoPublisher.send(shouldHighlight)
        }
        .store(in: &subscriptions)
        shopSummaryInfoView.reviewButtonTappedPublisher
            .sink { [weak self] in
                self?.reviewButtonTappedPublisher.send()
            }
            .store(in: &subscriptions)
        shopSummaryInfoView.phoneButtonTappedPublisher
            .sink { [weak self] in
                self?.phoneButtonTappedPublisher.send()
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - update
    func update(contentOffset: CGPoint) {
        menuGroupNameCollectionView.contentOffset = contentOffset
    }
    
    func selectItem(at indexPath: IndexPath) {
        menuGroupNameCollectionView.configure(selectedIndexPath: indexPath)
        menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension ShopSummaryTableViewTableHeaderView {
    
    func updateInfoView(orderShopSummary: OrderShopSummary, isFromOrder: Bool) {
        imagesCollectionView.configure(orderImage: orderShopSummary.images)
        imagesPageControl.numberOfPages = orderShopSummary.images.count
        if orderShopSummary.images.count <= 1 {
            imagesPageControl.isHidden = true
        }
        shopSummaryInfoView.configure(orderShopSummary: orderShopSummary, isFromOrder: isFromOrder)
    }
    
    func configure(phonenumber: String) {
        shopSummaryInfoView.configure(phonenumber: phonenumber)
    }
    
    func configure(minOrderAmount: Int, minDeliveryTip: Int, maxDelieveryTip: Int, isFromOrder: Bool) {
        shopSummaryInfoView.configure(minOrderAmount: minOrderAmount,
                                      minDeliveryTip: minDeliveryTip,
                                      maxDelieveryTip: maxDelieveryTip,
                                      isFromOrder: isFromOrder)
    }
    
    func updateMenusGroups(orderShopMenusGroups: OrderShopMenusGroups) {
        menuGroupNameCollectionView.configure(menuGroup: orderShopMenusGroups.menuGroups)
    }
    func updateIsAvailables(delivery: Bool, takeOut: Bool = false, payBank: Bool, payCard: Bool) {
        shopSummaryInfoView.configure(isDelieveryAvailable: delivery, isTakeoutAvailable: takeOut,payCard: payCard, payBank: payBank)
    }
}

extension ShopSummaryTableViewTableHeaderView {
    
    private func setUpLayout() {
        [separatorView, imagesCollectionView, imagesPageControl, shopSummaryInfoView, menuGroupNameCollectionView].forEach {
            addSubview($0)
        }
    }
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
        shopSummaryInfoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(imagesCollectionView.snp.bottom)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(shopSummaryInfoView.snp.bottom)
            $0.height.equalTo(8)
        }
        menuGroupNameCollectionView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()            
            $0.height.equalTo(66)
        }
    }
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
