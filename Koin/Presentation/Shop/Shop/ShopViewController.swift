//
//  ShopViewController.swift
//  koin
//
//  Created by 김나훈 on 10/3/24.
//

import Combine
import UIKit
import SnapKit

final class ShopViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopViewModel
    private let inputSubject = PassthroughSubject<ShopViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var didTapBack = false
    weak var coordinator: ShopCoordinator?

    
    // MARK: - UI Components
    private let dummyNavigationBar = UIView().then {
        $0.backgroundColor = .appColor(.newBackground)
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryCollectionView = OrderCategoryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
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
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12,
                                                       bottom: 0, trailing: 0)
        
        $0.contentHorizontalAlignment = .leading
        
        $0.configuration = config
        $0.tintColor = .appColor(.neutral500)
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
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
    
    private let openShopToggleButton = UIButton(type: .custom).then { button in
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .filterIcon1)?.withRenderingMode(.alwaysTemplate)
        config.imagePadding = 6
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        button.configuration = config
        
        button.configurationUpdateHandler = { button in
            let selectedBackgroundColor = UIColor.appColor(.new500)
            let unselectedBackgroundColor = UIColor.white
            let selectedTitleColor = UIColor.white
            let unselectedTitleColor = UIColor.appColor(.neutral400)
            
            var newConfig = button.configuration
            let color = button.isSelected ? selectedTitleColor : unselectedTitleColor
            
            newConfig?.background.backgroundColor = button.isSelected ? selectedBackgroundColor : unselectedBackgroundColor
            newConfig?.baseForegroundColor = color
            newConfig?.background.cornerRadius = 17
            
            newConfig?.attributedTitle = AttributedString("영업중", attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor: color
            ]))
            
            button.configuration = newConfig
        }
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.04
        button.layer.masksToBounds = false
    }
    
    private let eventShopCollectionView = EventShopCollectionView(
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
    
    private let emptyResultImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .orderEmptyLogo)
    }

    private lazy var emptyResultStackView = UIStackView(arrangedSubviews: [emptyResultImageView,emptyResultLabel]).then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.isHidden = true
        $0.backgroundColor = UIColor.appColor(.newBackground)
        $0.isUserInteractionEnabled = false
    }


    
    private let shopCollectionView = ShopInfoCollectionView()
    
    // MARK: - Initialization
    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "주변상점"
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
        hideKeyboardWhenTappedAround()
        setAddTarget()
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .transparentBlack)
        self.didTapBack = false
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
        
        guard let navigationController else { return }
        let navigationBarHeight: CGFloat = UIApplication.topSafeAreaHeight() + navigationController.navigationBar.frame.height
        dummyNavigationBar.snp.updateConstraints {
            $0.height.equalTo(navigationBarHeight)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !didTapBack, (self.parent?.isMovingFromParent ?? false) else { return }
        didTapBack = true
        
        let previousPage = viewModel.selectedCategoryName
        let currentPage = "메인"
        let isSwipe = navigationController?.transitionCoordinator?.isInteractive ?? false
        let eventCategory: EventParameter.EventCategory = isSwipe ? .swipe : .click
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategoriesBack))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesBack, eventCategory, currentPage, previousPage, nil, nil, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
        eventShopCollectionView.stopAutoScroll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main)
            .sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case let .changeFilteredShops(shops, id):
                self.updateFilteredShops(shops)
                self.updateFilteredCategory(id)
            case let .putImage(response):
                self.putImage(data: response)
            case let .updateEventShops(eventShops):
                self.updateEventShops(eventShops)
            case let .updateSortButtonTitle(newTitle):
                var config = self.sortButton.configuration ?? .plain()
                var attribute = AttributedString(newTitle)
                attribute.font = UIFont.appFont(.pretendardBold, size: 14)
                attribute.foregroundColor = UIColor.appColor(.new500)
                config.attributedTitle = attribute
                self.sortButton.configuration = config
            default: break
            }
        }.store(in: &subscriptions)

        eventShopCollectionView.scrollPublisher.sink { [weak self] index in
            self?.eventIndexLabel.text = index
        }.store(in: &subscriptions)

        shopCollectionView.sortOptionDidChangePublisher.sink { [weak self] sortType in
            self?.inputSubject.send(.sortOptionDidChange(sortType))
        }.store(in: &subscriptions)

        categoryCollectionView.selectedCategoryPublisher.sink { [weak self] categoryId in
            guard let self else { return }
            
            let previousPage = self.viewModel.selectedCategoryName
            let currentPage  = self.viewModel.categoryName(for: categoryId)
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, .click, currentPage, previousPage, nil, nil, .shopCategories))
            
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
            self.inputSubject.send(.changeCategory(categoryId))
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let previousPage = self?.viewModel.selectedCategoryName ?? "알 수 없음"
            let currentPage = shopName
            
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, currentPage, previousPage, nil, nil, .shopClick))

            self?.coordinator?.navigateToShopSummary(shopId: shopId, shopName: shopName, categoryName: previousPage)
        }
        .store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        searchBarButton.addTarget(self, action: #selector(searchBarButtonTapped), for: .touchUpInside)
        
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        openShopToggleButton.addAction(UIAction { [weak self] _ in self?.handleOpenShopToggle() }, for: .touchUpInside)
    }
}

// MARK: - @objc
extension ShopViewController {
    @objc private func searchBarButtonTapped() {
        coordinator?.navigateToShopSearch(categoryName: viewModel.selectedCategoryName)
    }

    @objc private func sortButtonTapped() {
        let categoryName = viewModel.selectedCategoryName
        
        coordinator?.showSortOptionSheet(currentType: viewModel.currentSortType) { [weak self] sort in
            guard let self else { return }
            
            self.inputSubject.send(.sortOptionDidChange(sort))
            
            let value: String
            switch sort {
            case .basic:  value = "check_default_\(categoryName)"
            case .review: value = "check_review_\(categoryName)"
            case .rating: value = "check_star_\(categoryName)"
            }
            
            self.inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCan, .click, value))
        }
    }
}

extension ShopViewController {
    private func handleOpenShopToggle() {
        openShopToggleButton.isSelected.toggle()
        let categoryName = viewModel.selectedCategoryName
        let value = "check_open_\(categoryName)"
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCan, .click, value))
        inputSubject.send(.filterOpenShops(openShopToggleButton.isSelected))
    }

    private func updateFilteredShops(_ shops: [Shop]) {
        let isEmpty = shops.isEmpty
        shopCollectionView.isHidden = isEmpty
        emptyResultStackView.isHidden = !isEmpty

        if !isEmpty {
            shopCollectionView.updateShop(shops)
        }
        shopCollectionView.snp.remakeConstraints {
            $0.top.equalTo(openShopToggleButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            let height = isEmpty ? 0 : shopCollectionView.calculateShopListHeight()
            $0.height.equalTo(height)
            $0.bottom.equalToSuperview().offset(-32)
        }
        view.layoutIfNeeded()
    }

    private func updateFilteredCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }

    private func putImage(data: ShopCategoryDto) {
        categoryCollectionView.updateCategories(data.shopCategories)
    }

    private func updateEventShops(_ eventShops: [EventDto]) {
        let eventShops: [EventDto] = []
        eventShopCollectionView.isHidden = eventShops.isEmpty
        eventIndexLabel.isHidden = eventShops.isEmpty
        if !eventShops.isEmpty {
            shopCollectionView.snp.remakeConstraints {
                $0.top.equalTo(eventShopCollectionView.snp.bottom).offset(14)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
                $0.height.equalTo(1)
                $0.bottom.equalToSuperview().offset(-32)
            }
            eventShopCollectionView.setEventShops(eventShops)
            eventIndexLabel.text = "1/\(eventShops.count)"
        }
    }
}

// MARK: - Configure View
extension ShopViewController {
    private func setUpLayOuts() {
        [scrollView, dummyNavigationBar].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [categoryCollectionView, searchBarButton, sortButton, openShopToggleButton, eventShopCollectionView, eventIndexLabel, shopCollectionView,emptyResultStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dummyNavigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        searchBarButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
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
            $0.width.greaterThanOrEqualTo(75)
            $0.height.equalTo(34)
        }

        openShopToggleButton.snp.makeConstraints {
            $0.leading.equalTo(sortButton.snp.trailing).offset(16)
            $0.centerY.equalTo(sortButton)
            $0.height.equalTo(34)
            $0.width.greaterThanOrEqualTo(74)
        }

        eventShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(openShopToggleButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        eventIndexLabel.snp.makeConstraints {
            $0.bottom.equalTo(eventShopCollectionView.snp.bottom).offset(-12)
            $0.trailing.equalToSuperview().offset(-44)
            $0.width.greaterThanOrEqualTo(40)
            $0.height.equalTo(14)
        }
        
        shopCollectionView.snp.makeConstraints {
            $0.top.equalTo(openShopToggleButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-32)
        }
        emptyResultStackView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}

extension ShopViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView == self.scrollView {
            makeScrollLog()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            makeScrollLog()
        }
    }
    
    private func makeScrollLog() {
        let categoryName = viewModel.selectedCategoryName
        
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCategories, .scroll, "scroll in \(categoryName)"))
    }
}
