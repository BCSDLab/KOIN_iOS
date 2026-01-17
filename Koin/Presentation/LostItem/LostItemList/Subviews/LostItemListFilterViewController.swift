//
//  LostItemListFilterViewController.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import Combine

final class LostItemListFilterViewController: UIViewController {
    
    // MARK: - Properties
    private let onResetFilterButtonTapped: ()->Void
    private let onApplyFilterButtonTapped: (FetchLostItemRequest)->Void
    @Published private var filterState: FetchLostItemRequest
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let filterTitleLabel = UILabel().then {
        $0.text = "필터"
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.tintColor = .appColor(.primary500)
    }
    private let closeButton = UIButton().then {
        $0.setImage(.appImage(asset: .cancelNeutral500), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    private let separatorView0 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    private let authorFilterTitleLabel = UILabel().then {
        $0.text = "목록"
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    private let authorButtonsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
    }
    private let authorAllButton = LostItemListFilterButton(text: "전체", isSelected: true)
    private let authorMineButton = LostItemListFilterButton(text: "내 게시물", isSelected: false)
    
    private let separatorView1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    private let typeFilterTitleLabel = UILabel().then {
        $0.text = "물품 카테고리"
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    private let typeButtonsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
    }
    private let typeAllButton = LostItemListFilterButton(text: "전체", isSelected: true)
    private let typeFoundButton = LostItemListFilterButton(text: "습득물", isSelected: false)
    private let typeLostButton = LostItemListFilterButton(text: "분실물", isSelected: true)
    
    private let separatorView2 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    private let categoryFilterTitleLabel = UILabel().then {
        $0.text = "물품 종류"
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    private let categoryButtonsStackView1 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
    }
    private let categoryAllButton = LostItemListFilterButton(text: "전체", isSelected: true)
    private let categoryCardButton = LostItemListFilterButton(text: "카드", isSelected: false)
    private let categoryWalletButton = LostItemListFilterButton(text: "지갑", isSelected: false)
    private let categoryButtonsStackView2 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
    }
    private let categoryIdCardButton = LostItemListFilterButton(text: "신분증", isSelected: false)
    private let categoryElectronicDeviceButton = LostItemListFilterButton(text: "전자제품", isSelected: false)
    private let categoryOtherButton = LostItemListFilterButton(text: "기타", isSelected: false)
    
    private let stateTitleLabel = UILabel().then {
        $0.text = "물품 상태"
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    private let stateButtonsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillProportionally
    }
    private let stateAllButton = LostItemListFilterButton(text: "전체", isSelected: true)
    private let stateNotFoundButton = LostItemListFilterButton(text: "찾는중", isSelected: false)
    private let stateFoundButton = LostItemListFilterButton(text: "찾음", isSelected: false)
    
    private let resetFilterButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("초기화", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardBold, size: 16),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.image = UIImage.appImage(asset: .refresh)
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        $0.configuration = configuration
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    private let applyFilterButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(string: "적용하기", attributes: [
            .font : UIFont.appFont(.pretendardBold, size: 16),
            .foregroundColor : UIColor.appColor(.neutral0)
        ]), for: .normal)
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let separatorView3 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    // MARK: - Initiailizer
    init(filterState: FetchLostItemRequest,
         onResetFilterButtonTapped: @escaping () -> Void,
         onApplyFilterButtonTapped: @escaping (FetchLostItemRequest) -> Void) {
        self.filterState = filterState
        self.onResetFilterButtonTapped = onResetFilterButtonTapped
        self.onApplyFilterButtonTapped = onApplyFilterButtonTapped
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
        bind()
    }
    
    private func bind() {
        $filterState.sink { [weak self] state in
            guard let self else { return }
            authorAllButton.isSelected = (state.author == .all)
            authorMineButton.isSelected = (state.author == .my)
            typeAllButton.isSelected = (state.type == nil)
            typeFoundButton.isSelected = (state.type == .found)
            typeLostButton.isSelected = (state.type == .lost)
            categoryAllButton.isSelected = (state.category == .all)
            categoryCardButton.isSelected = (state.category == .card)
            categoryWalletButton.isSelected = (state.category == .wallet)
            categoryIdCardButton.isSelected = (state.category == .id)
            categoryElectronicDeviceButton.isSelected = (state.category == .electronics)
            categoryOtherButton.isSelected = (state.category == .etc)
            stateAllButton.isSelected = (state.foundStatus == .all)
            stateNotFoundButton.isSelected = (state.foundStatus == .notFound)
            stateFoundButton.isSelected = (state.foundStatus == .found)
        }.store(in: &subscriptions)
    }
}

extension LostItemListFilterViewController {
    
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        authorAllButton.addTarget(self, action: #selector(authorAllButtonTapped), for: .touchUpInside)
        authorMineButton.addTarget(self, action: #selector(authorMineButtonTapped), for: .touchUpInside)
        typeAllButton.addTarget(self, action: #selector(typeAllButtonTapped), for: .touchUpInside)
        typeFoundButton.addTarget(self, action: #selector(typeFoundButtonTapped), for: .touchUpInside)
        typeLostButton.addTarget(self, action: #selector(typeLostButtonTapped), for: .touchUpInside)
        categoryAllButton.addTarget(self, action: #selector(categoryAllButtonTapped), for: .touchUpInside)
        categoryCardButton.addTarget(self, action: #selector(categoryCardButtonTapped), for: .touchUpInside)
        categoryWalletButton.addTarget(self, action: #selector(categoryWalletButtonTapped), for: .touchUpInside)
        categoryIdCardButton.addTarget(self, action: #selector(categoryIdCardButtonTapped), for: .touchUpInside)
        categoryElectronicDeviceButton.addTarget(self, action: #selector(categoryElectronicDeviceButtonTapped), for: .touchUpInside)
        categoryOtherButton.addTarget(self, action: #selector(categoryOtherButtonTapped), for: .touchUpInside)
        stateAllButton.addTarget(self, action: #selector(stateAllButtonTapped), for: .touchUpInside)
        stateNotFoundButton.addTarget(self, action: #selector(stateNotFoundButtonTapped), for: .touchUpInside)
        stateFoundButton.addTarget(self, action: #selector(stateFoundButtonTapped), for: .touchUpInside)
        resetFilterButton.addTarget(self, action: #selector(resetFilterButtonTapped), for: .touchUpInside)
        applyFilterButton.addTarget(self, action: #selector(applyFilterButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismissView()
    }
    @objc private func authorAllButtonTapped() {
        filterState.author = .all
    }
    @objc private func authorMineButtonTapped() {
        filterState.author = .my
    }
    @objc private func typeAllButtonTapped() {
        filterState.type = nil
    }
    @objc private func typeFoundButtonTapped() {
        filterState.type = .found
    }
    @objc private func typeLostButtonTapped() {
        filterState.type = .lost
    }
    @objc private func categoryAllButtonTapped() {
        filterState.category = .all
    }
    @objc private func categoryCardButtonTapped() {
        filterState.category = .card
    }
    @objc private func categoryWalletButtonTapped() {
        filterState.category = .wallet
    }
    @objc private func categoryIdCardButtonTapped() {
        filterState.category = .id
    }
    @objc private func categoryElectronicDeviceButtonTapped() {
        filterState.category = .electronics
    }
    @objc private func categoryOtherButtonTapped() {
        filterState.category = .etc
    }
    @objc private func stateAllButtonTapped() {
        filterState.foundStatus = .all
    }
    @objc private func stateNotFoundButtonTapped() {
        filterState.foundStatus = .notFound
    }
    @objc private func stateFoundButtonTapped() {
        filterState.foundStatus = .found
    }
    @objc private func resetFilterButtonTapped() {
        filterState = FetchLostItemRequest()
    }
    @objc private func applyFilterButtonTapped() {
        onApplyFilterButtonTapped(filterState)
    }
}

extension LostItemListFilterViewController {
    
    private func setUpLayouts() {
        [authorAllButton, authorMineButton].forEach {
            authorButtonsStackView.addArrangedSubview($0)
        }
        [typeAllButton, typeFoundButton, typeLostButton].forEach {
            typeButtonsStackView.addArrangedSubview($0)
        }
        [categoryAllButton, categoryCardButton, categoryWalletButton].forEach {
            categoryButtonsStackView1.addArrangedSubview($0)
        }
        [categoryIdCardButton, categoryElectronicDeviceButton, categoryOtherButton].forEach {
            categoryButtonsStackView2.addArrangedSubview($0)
        }
        [stateAllButton, stateNotFoundButton, stateFoundButton].forEach {
            stateButtonsStackView.addArrangedSubview($0)
        }
        [filterTitleLabel, closeButton, separatorView0,
         authorFilterTitleLabel, authorButtonsStackView, separatorView1,
         typeFilterTitleLabel, typeButtonsStackView, separatorView2,
         categoryFilterTitleLabel, categoryButtonsStackView1, categoryButtonsStackView2,
         stateTitleLabel, stateButtonsStackView,
         resetFilterButton, applyFilterButton, separatorView3].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        [authorFilterTitleLabel, categoryFilterTitleLabel, typeFilterTitleLabel, stateTitleLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(26)
            }
        }
        [authorAllButton, categoryAllButton, typeAllButton, stateAllButton,
         authorMineButton, typeFoundButton, typeLostButton, categoryCardButton, categoryWalletButton, categoryIdCardButton, categoryElectronicDeviceButton, categoryOtherButton, stateNotFoundButton, stateFoundButton].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
            }
        }
        
        filterTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(29)
        }
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(filterTitleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        separatorView0.snp.makeConstraints {
            $0.top.equalTo(filterTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        authorFilterTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView0.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(32)
        }
        authorButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(authorFilterTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(34)
        }
        separatorView1.snp.makeConstraints {
            $0.top.equalTo(authorButtonsStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(1)
        }
        typeFilterTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView1.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(32)
        }
        typeButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(typeFilterTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(34)
        }
        separatorView2.snp.makeConstraints {
            $0.top.equalTo(typeButtonsStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(1)
        }
        categoryFilterTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView2.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(32)
        }
        categoryButtonsStackView1.snp.makeConstraints {
            $0.top.equalTo(categoryFilterTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(34)
        }
        categoryButtonsStackView2.snp.makeConstraints {
            $0.top.equalTo(categoryButtonsStackView1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(32)
        }
        stateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryButtonsStackView2.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(32)
        }
        stateButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(stateTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        resetFilterButton.snp.makeConstraints {
            $0.width.equalTo(98)
            $0.height.equalTo(48)
            $0.top.equalTo(stateButtonsStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(32)
        }
        applyFilterButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(resetFilterButton)
            $0.leading.equalTo(resetFilterButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-32)
        }
        separatorView3.snp.makeConstraints {
            $0.top.equalTo(resetFilterButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
