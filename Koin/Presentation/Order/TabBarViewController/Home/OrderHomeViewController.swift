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
    private let scrollView = UIScrollView()
    
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
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
    }
    
    private let categoryCollectionView = OrderCategoryCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
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
    )
    
    private let eventOrderShopCollectionView = EventOrderShopCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
        layout.scrollDirection = .horizontal
        $0.isHidden = true
    }

    private let eventIndexLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.textColor = .appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.6)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
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

    private let emptyResultImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .orderEmptyLogo)
    }

    private let emptyResultLabel = UILabel().then {
        let firstLine = "이용 가능한 가게가 없어요"
        let secondLine = "조건을 변경하고 다시 검색해주세요"
        let text = "\(firstLine)\n\(secondLine)"

        let attributedText = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center

        attributedText.addAttribute(.font, value: UIFont.appFont(.pretendardBold, size: 18), range: NSRange(location: 0, length: firstLine.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.appColor(.new500), range: NSRange(location: 0, length: firstLine.count))

        let secondLineRange = NSRange(location: firstLine.count + 1, length: secondLine.count)
        attributedText.addAttribute(.font, value: UIFont.appFont(.pretendardMedium, size: 14), range: secondLineRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral600), range: secondLineRange)

        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))

        $0.attributedText = attributedText
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private lazy var emptyResultStackView = UIStackView(arrangedSubviews: [emptyResultImageView, emptyResultLabel]).then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.isHidden = true
        $0.backgroundColor = UIColor.appColor(.newBackground)
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
        orderShopCollectionView.delegate = self

        configureView()
        setAddTarget()
        bind()
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
            case let .updateEventShops(eventShops):
                self?.updateEventShops(eventShops)
            case let .putImage(response):
                self?.putImage(data: response)
            case .errorOccurred(let error):
                if let serverError = error as? ServerErrorDTO {
                    self?.showAlert(serverError.message)
                } else {
                    self?.showAlert(error.localizedDescription)
                }

            default:
                break
            }
        }.store(in: &subscriptions)
        
        filterCollectionView.filtersDidChange
            .sink { [weak self] filters in
                self?.inputSubject.send(.filtersDidChange(filters))
            }
            .store(in: &subscriptions)

        categoryCollectionView.selectedCategoryPublisher
            .removeDuplicates()
            .sink { [weak self] id in
                self?.inputSubject.send(.categoryDidChange(id))
            }
            .store(in: &subscriptions)
            
        filterCollectionView.minPriceCellTapped
            .sink { [weak self] in
                self?.minPriceButtonTapped()
            }
            .store(in: &subscriptions)
        
        eventOrderShopCollectionView.scrollPublisher
            .sink { [weak self] index in
                self?.eventIndexLabel.text = index
            }
            .store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        searchBarButton.addTarget(self, action: #selector(searchBarButtonTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
}

extension OrderHomeViewController {
    // FIXME: - 지워
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func searchBarButtonTapped() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let orderService = DefaultOrderService()
        let orderRepository = DefaultOrderShopRepository(service: orderService)

        let fetchOrderEventShopUseCase = DefaultFetchOrderEventShopUseCase(orderShopRepository: orderRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchOrderShopListUseCase = DefaultFetchOrderShopListUseCase(orderShopRepository: orderRepository)
        let searchOrderShopUseCase = DefaultSearchOrderShopUseCase(orderShopRepository: orderRepository)

        let searchVC = OrderSearchViewController(
            viewModel: OrderHomeViewModel(
                fetchOrderEventShopUseCase: fetchOrderEventShopUseCase,
                fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
                fetchOrderShopListUseCase: fetchOrderShopListUseCase,
                searchOrderShopUseCase: searchOrderShopUseCase,
                selectedId: 1
            )
        )

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
            self.inputSubject.send(.minPriceDidChange(price))
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
        orderShopCollectionView.updateShop(shops) { [weak self] in
            guard let self else { return }

            let dynamicHeight = self.orderShopCollectionView.calculateCollectionViewHeight()

            self.orderShopCollectionView.snp.remakeConstraints {
                if self.eventOrderShopCollectionView.isHidden {
                    $0.top.equalTo(self.sortButton.snp.bottom).offset(24)
                } else {
                    $0.top.equalTo(self.eventOrderShopCollectionView.snp.bottom).offset(14)
                }
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
                $0.bottom.equalToSuperview().offset(-32)
                $0.height.equalTo(dynamicHeight)
            }

            self.orderShopCollectionView.isHidden = shops.isEmpty
            self.emptyResultStackView.isHidden = !shops.isEmpty

            if shops.isEmpty {
                self.emptyResultStackView.snp.remakeConstraints { make in
                    if self.eventOrderShopCollectionView.isHidden {
                        make.top.equalTo(self.sortButton.snp.bottom).offset(24)
                    } else {
                        make.top.equalTo(self.eventOrderShopCollectionView.snp.bottom).offset(14)
                    }
                    make.centerX.equalToSuperview()
                }
            }

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func updateFilteredOrderShopsCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }
    
    private func updateEventShops(_ eventShops: [OrderShopEvent]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let now = Date()
        let ongoingEvents = eventShops.filter { event in
            guard let start = dateFormatter.date(from: event.startDate),
                  let end = dateFormatter.date(from: event.endDate) else {
                return false
            }
            return start <= now && now <= end
        }
        let limitedEvents = Array(ongoingEvents.prefix(10))
        let isEmpty = limitedEvents.isEmpty

        eventOrderShopCollectionView.isHidden = isEmpty
        eventIndexLabel.isHidden = isEmpty

        orderShopCollectionView.snp.remakeConstraints {
            if isEmpty {
                $0.top.equalTo(sortButton.snp.bottom).offset(24)
            } else {
                $0.top.equalTo(eventOrderShopCollectionView.snp.bottom).offset(14)
            }
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-32)
        }

        if isEmpty {
            eventOrderShopCollectionView.stopAutoScroll()
            return
        }
        eventOrderShopCollectionView.setEventShops(limitedEvents)
        eventIndexLabel.text = "1/\(limitedEvents.count)"
        eventOrderShopCollectionView.startAutoScroll(interval: 4.0)

        eventOrderShopCollectionView.cellTapPublisher
            .sink { [weak self] (shopId, _) in
                guard let self = self else { return }
                let detailVC = OrderHomeDetailWebViewController(shopId: shopId, isFromOrder: true)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(detailVC, animated: true)
                self.tabBarController?.tabBar.isHidden = true
            }
            .store(in: &subscriptions)
    }
}

extension OrderHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == orderShopCollectionView {
            let orderableShopId = viewModel.getOrderableShopId(at: indexPath.item)
            let detailVC = OrderHomeDetailWebViewController(shopId: orderableShopId, isFromOrder: true)
            self.tabBarController?.tabBar.isHidden = true
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension OrderHomeViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [searchBarButton, categoryCollectionView, sortButton, filterCollectionView, orderShopCollectionView, eventOrderShopCollectionView, eventIndexLabel, emptyResultStackView].forEach {
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
        
        eventOrderShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(filterCollectionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        eventIndexLabel.snp.makeConstraints {
            $0.bottom.equalTo(eventOrderShopCollectionView.snp.bottom).offset(-12)
            $0.trailing.equalToSuperview().offset(-44)
            $0.width.greaterThanOrEqualTo(40)
            $0.height.equalTo(14)
        }
        
        orderShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(0)
        }

        emptyResultStackView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureView() {
        self.view.backgroundColor = UIColor.appColor(.newBackground)
        setUpLayOuts()
        setUpConstraints()
    }
}
