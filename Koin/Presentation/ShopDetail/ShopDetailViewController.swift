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
        configureRightBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar(style: .orderTransparent)
        configureView()
    }
}

extension ShopDetailViewController {
    
    // MARK: - bind
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.sink { [weak self] output in
            switch output {
            case .updateImagesUrls(let urls):
                self?.imagesCollectionView.bind(urls: urls)
                self?.imagesPageControl.numberOfPages = urls.count
            case .updateInfoView(let orderShop):
                self?.infoView.bind(rate: orderShop.ratingAverage, review: orderShop.reviewCount, isDelieveryAvailable: orderShop.isDeliveryAvailable, isTakeoutAvailable: orderShop.isTakeoutAvailable, minOrder: orderShop.minimumOrderAmount, minTip: orderShop.minimumDeliveryTip, maxTip: orderShop.maximumDeliveryTip, introduction: "안녕하세요 안녕하세요 반갑습니다 반갑습니다") // introduction ??
            case .updateMenus(let orderShopMenus):
                var menuGroupName: [String] = []
                orderShopMenus.forEach {
                    menuGroupName.append($0.menuGroupName)
                }
                self?.menuGroupNameCollectionView.bind(menuGroupName: menuGroupName)
            }
        }
        .store(in: &subscriptions)
        
        imagesCollectionView.didScrollOutputSubject.sink { [weak self] currentPage in
            self?.imagesPageControl.currentPage = currentPage
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - configureRightBarButton
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.appImage(asset: .shoppingCartWhite)?.resize(to: CGSize(width: 24, height: 24)), style: .plain, target: self, action: #selector(navigationButtonTapped))
    }
    
    // MARK: - ConfigureView
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview() //필요할까?
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
            $0.height.equalTo(34)
        }
    }
    private func setUpLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [imagesCollectionView, imagesPageControl, infoView, separatorView, menuGroupNameCollectionView].forEach {
            contentView.addSubview( $0 )
        }
    }
    private func configureView(){
        setUpLayout()
        setUpConstraints()
    }
    
    // MARK: - @objc
    @objc private func navigationButtonTapped() {
        navigationController?.pushViewController(UIViewController(), animated: true)
    }
}
