//
//  OrderHomeViewController.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import SnapKit
import Combine

final class OrderHomeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: OrderHomeViewModel
    private let inputSubject: PassthroughSubject<OrderHomeViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var currentSortType: SortType = .basic
    private var currentMinPrice: Int? = nil
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let contentView = UIView()
    
    private let searchBarButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        
        if let base = UIImage.appImage(asset: .search){
            let sized = base.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
            )
            config.image = sized.withTintColor(
                .appColor(.neutral500),
                renderingMode: .alwaysTemplate
            )
        }
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        var titleAttribute = AttributedString("검색어를 입력해주세요.")
        titleAttribute.font = UIFont.appFont(.pretendardRegular, size: 14)
        titleAttribute.foregroundColor = UIColor.appColor(.neutral400)
        config.attributedTitle = titleAttribute
        
        config.background.backgroundColor = .white
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16,
                                                       bottom: 0, trailing: 160)
        
        $0.configuration = config
        $0.tintColor = .appColor(.neutral500)
        
        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
    }
    
    private let categoryCollectionView = OrderCategoryCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then { collectionView in
    }
    
    private let sortButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()

        var titleAttribute = AttributedString("기본순")
        titleAttribute.font = UIFont.appFont(.pretendardBold, size: 14)
        titleAttribute.foregroundColor = UIColor.appColor(.new500)
        config.attributedTitle = titleAttribute

        if let img = UIImage.appImage(asset: .chevronDown)?.withRenderingMode(.alwaysTemplate) {
            config.image = img
            config.imagePlacement = .trailing
            config.imagePadding = 6
        }

        config.contentInsets = .init(top: 6, leading: 8, bottom: 6, trailing: 8)

        config.background.backgroundColor = UIColor.appColor(.newBackground)
        config.background.cornerRadius = 24
        config.background.strokeWidth = 1
        config.background.strokeColor = UIColor.appColor(.new500)

        $0.configuration = config
        $0.tintColor = .appColor(.new500)
        $0.sizeToFit()
    }
    
    private let filterCollectionView = FilterCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then { collectionView in
    }

    private lazy var orderShopCollectionView = OrderShopCollectionView(
        frame: .zero,
        collectionViewLayout: {
            let flowLayout = UICollectionViewFlowLayout().then {
                $0.scrollDirection = .vertical
                $0.minimumLineSpacing = 12
                let screenWidth = UIScreen.main.bounds.width
                let cellWidth = screenWidth - 48
                $0.itemSize = CGSize(width: cellWidth, height: 128)
            }
            return flowLayout
        }()
    ).then {
        $0.isScrollEnabled = false
    }

    // MARK: - Initialization
    init(viewModel: OrderHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
        bind()
        orderShopCollectionView.delegate = self
        inputSubject.send(.viewDidLoad)
    }
    
    // MARK: - Bind
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .changeFilteredOrderShops(Ordershops, id):
                self?.updateFilteredOrderShops(Ordershops)
                self?.updateFilteredOrderShopsCategory(id)
            case let .putImage(response):
                self?.putImage(data: response)
            case let .showSearchedResult(keywords):
                break
            case let .changeFilteredShops(shops, id):
                break
            }
        }.store(in: &subscriptions)
        
        filterCollectionView.filtersDidChange
            .sink { [weak self] filters in
                self?.inputSubject.send(.filtersDidChange(filters))
            }
            .store(in: &subscriptions)

        categoryCollectionView.selectedCategoryPublisher
            .sink { [weak self] id in
                self?.inputSubject.send(.categoryDidChange(id))
            }
            .store(in: &subscriptions)
            
        filterCollectionView.minPriceCellTapped
            .sink { [weak self] in
                self?.minPriceButtonTapped()
            }
            .store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        searchBarButton.addTarget(self, action: #selector(searchBarButtonTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
}

extension OrderHomeViewController {
    @objc private func searchBarButtonTapped() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let orderService = DefaultOrderService()
        let orderRepository = DefaultOrderShopRepository(service: orderService)
        
        let searchVC = OrderSearchViewController(viewModel: OrderHomeViewModel(fetchShopCategoryListUseCase: DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository), fetchOrderShopListUseCase: DefaultFetchOrderShopListUseCase(orderShopRepository: orderRepository), searchOrderShopUseCase: DefaultSearchOrderShopUseCase(orderShopRepository: orderRepository), selectedId: 1))
        
        let navController = UINavigationController(rootViewController: searchVC)
        if #available(iOS 13.0, *) {
            navController.modalPresentationStyle = .fullScreen
        } else {
            navController.modalPresentationStyle = .overFullScreen
        }
        present(navController, animated: true, completion: nil)
    }
    
    private func putImage(data: ShopCategoryDTO) {
        categoryCollectionView.updateCategories(data.shopCategories)
    }
    
    @objc private func sortButtonTapped() {
        guard presentedViewController == nil else { return }
        
        let bottomSheetViewController = SortOptionSheetViewController(current: self.currentSortType)
        bottomSheetViewController.onOptionSelected = { [weak self] sort in
            guard let self = self else { return }
            
            self.currentSortType = sort

            var config = self.sortButton.configuration ?? .plain()
            
            var attribute = AttributedString(sort.title)
            attribute.font = UIFont.appFont(.pretendardBold, size: 14)
            attribute.foregroundColor = UIColor.appColor(.new500)
            
            config.attributedTitle = attribute
            self.sortButton.configuration = config
            
            self.inputSubject.send(.sortDidChange(sort.fetchSortType))
        }
        
        bottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetViewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent
                    .custom(identifier: .init("fixed233")) { _ in 233 }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = detent.identifier
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 32
        }
        present(bottomSheetViewController, animated: true)
    }
    
    @objc private func minPriceButtonTapped() {
        guard presentedViewController == nil else { return }
        
        let bottomSheetViewController = MinPriceSheetViewController(current: self.currentMinPrice)
        bottomSheetViewController.onOptionSelected = { [weak self] price in
            guard let self = self else { return }
            
            self.currentMinPrice = price
            self.filterCollectionView.updateMinPrice(price)
            
            // TODO: ViewModel에 최소주문금액 변경 이벤트 전달
            // self.inputSubject.send(.minPriceDidChange(price))
        }
        
        bottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetViewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent
                    .custom(identifier: .init("fixed280")) { _ in 280 }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = detent.identifier
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 32
        }
        present(bottomSheetViewController, animated: true)
    }
    
    private func updateFilteredOrderShops(_ shops: [OrderShop]) {
        orderShopCollectionView.updateShop(shops)
        orderShopCollectionView.snp.updateConstraints { make in
            make.height.equalTo(orderShopCollectionView.calculateDynamicHeight())
        }
    }
    
    private func updateFilteredOrderShopsCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }
}

extension OrderHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == orderShopCollectionView {
            let shopId = viewModel.getShopId(at: indexPath.item)
            let detailVC = OrderHomeDetailViewController(shopId: shopId)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension OrderHomeViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [searchBarButton, categoryCollectionView, sortButton, filterCollectionView, orderShopCollectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        searchBarButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBarButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(71)
        }
        
        sortButton.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34)
        }
        
        filterCollectionView.snp.makeConstraints {
            $0.leading.equalTo(sortButton.snp.trailing).offset(16)
            $0.centerY.equalTo(sortButton)
            $0.height.equalTo(34)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        orderShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(0)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = UIColor.appColor(.newBackground)
    }
}
