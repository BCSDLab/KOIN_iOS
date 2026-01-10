//
//  ShopInfoHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/10/26.
//

import UIKit
import Combine

final class ShopInfoHeaderView: UICollectionReusableView {
    
    // MARK: - Static
    static let identifier = "ShopInfoHeaderView"
    
    // MARK: - Properties
    let searchBarButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let sortButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let openShopToggleButtonPublisher = PassthroughSubject<Bool, Never>()
    
    let selectedCategoryPublisher = PassthroughSubject<Int, Never>()
    let eventShopCellTapPublisher = PassthroughSubject<(Int, String), Never>()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
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
    
    private let categoryCollectionView = OrderCategoryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let eventShopCollectionView = EventShopCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
        layout.minimumInteritemSpacing = 6
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
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAddTarget()
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetAddTarget
    private func setAddTarget() {
        searchBarButton.addTarget(self, action: #selector(searchBarButtonTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        openShopToggleButton.addTarget(self, action: #selector(openShopToggleButtonTapped), for: .touchUpInside)
    }
    @objc private func searchBarButtonTapped() {
        searchBarButtonTappedPublisher.send()
    }
    @objc private func sortButtonTapped() {
        sortButtonTappedPublisher.send()
    }
    @objc private func openShopToggleButtonTapped() {
        openShopToggleButton.isSelected.toggle()
        openShopToggleButtonPublisher.send(openShopToggleButton.isSelected)
    }
    
    // MARK: - bind
    private func bind() {
        categoryCollectionView.selectedCategoryPublisher.sink { [weak self] categoryId in
            self?.selectedCategoryPublisher.send(categoryId)
        }.store(in: &subscriptions)
        
        eventShopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            self?.eventShopCellTapPublisher.send((shopId, shopName))
        }.store(in: &subscriptions)
        
        eventShopCollectionView.scrollPublisher.sink { [weak self] index in
            self?.eventIndexLabel.text = index
        }.store(in: &subscriptions)
    }
    
    // MARK: - Public
    func updateFilteredCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }

    func putImage(data: ShopCategoryDto) {
        categoryCollectionView.updateCategories(data.shopCategories)
    }

    func updateEventShops(_ eventShops: [EventDto]) {
        eventShopCollectionView.isHidden = eventShops.isEmpty
        eventIndexLabel.isHidden = eventShops.isEmpty
        if !eventShops.isEmpty {
            eventShopCollectionView.snp.updateConstraints {
                $0.height.equalTo(100)
            }
            eventShopCollectionView.setEventShops(eventShops)
            eventIndexLabel.text = "1/\(eventShops.count)"
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func stopAutoScroll() {
        eventShopCollectionView.stopAutoScroll()
    }
    
    func updateSortButtonTitle(_ newTitle: String) {
        var config = self.sortButton.configuration ?? .plain()
        var attribute = AttributedString(newTitle)
        attribute.font = UIFont.appFont(.pretendardBold, size: 14)
        attribute.foregroundColor = UIColor.appColor(.new500)
        config.attributedTitle = attribute
        self.sortButton.configuration = config
    }
}


extension ShopInfoHeaderView {
    
    private func setUpLayout() {
        [searchBarButton, categoryCollectionView, sortButton, openShopToggleButton, eventShopCollectionView, eventIndexLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
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
            $0.height.equalTo(0)
        }
        eventIndexLabel.snp.makeConstraints {
            $0.bottom.equalTo(eventShopCollectionView.snp.bottom).offset(-12)
            $0.trailing.equalToSuperview().offset(-44)
            $0.width.greaterThanOrEqualTo(40)
            $0.height.equalTo(14)
        }
    }
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
