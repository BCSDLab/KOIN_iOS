//
//  ShopDetailTableViewTableHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/22/25.
//

import UIKit
import Combine

final class ShopDetailTableViewTableHeaderView: UIView {
    
    // MARK: - Properties
    var subscriptions: Set<AnyCancellable> = []
    let menuGroupDidScrollSubject = PassthroughSubject<CGPoint, Never>()
    let menuGroupDidSelectSubject = PassthroughSubject<IndexPath, Never>()
    
    // MARK: - Components
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
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configureInfoView(orderImage: [OrderImage], numberOfPages: Int, orderShopSummary: OrderShopSummary, isFromOrder: Bool) {
        imagesCollectionView.configure(orderImage: orderImage)
        imagesPageControl.numberOfPages = numberOfPages
        infoView.configure(orderShopSummary: orderShopSummary, isFromOrder: isFromOrder)
    }
    func configureMenusGroups(menuGroup: [MenuGroup]) {
        menuGroupNameCollectionView.configure(menuGroup: menuGroup)
    }
    func configureIsAvailable(isDelieveryAvailable: Bool, isTakeoutAvailable: Bool?, payCard: Bool, payBank: Bool) {
        infoView.configure(isDelieveryAvailable: isDelieveryAvailable, isTakeoutAvailable: isTakeoutAvailable, payCard: payCard, payBank: payBank)
    }
    
    // MARK: - Bind
    private func bind() {
        // imagesCollectionView-didScroll
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
        
        // menuGroupNameCollectionView-didScroll
        menuGroupNameCollectionView.didScrollPublisher.sink { [weak self] contentOffset in
            self?.menuGroupNameCollectionView.contentOffset = contentOffset
            self?.menuGroupDidScrollSubject.send(contentOffset)
        }
        .store(in: &subscriptions)
        
        // menuGroupNameCollectionView-didSelect
        menuGroupNameCollectionView.didSelectCellPublisher.sink { [weak self] indexPath in
            self?.menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self?.menuGroupDidSelectSubject.send(indexPath)
        }
        .store(in: &subscriptions)
    }
}

extension ShopDetailTableViewTableHeaderView {
    
    // MARK: - update status of MenuGroupName CollectionView
    func update(contentOffset: CGPoint) {
        menuGroupNameCollectionView.contentOffset = contentOffset
    }
    func update(selectedIndexPath indexPath: IndexPath) {
        menuGroupNameCollectionView.indexPathsForSelectedItems?.forEach {
            menuGroupNameCollectionView.configureDeselectedCell($0)
        }
        menuGroupNameCollectionView.configureSelectedCell(indexPath)
        menuGroupNameCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension ShopDetailTableViewTableHeaderView {
    
    private func setUpLayouts() {
        [imagesCollectionView, imagesPageControl, infoView, separatorView, menuGroupNameCollectionView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints(){
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
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(66)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
