//
//  FilterBottomSheetView.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import UIKit
import Combine
import SnapKit
import Then

class FilterBottomSheetView: UIView {
    
    // MARK: - Properties
    weak var delegate: BottomSheetViewControllerBDelegate?
    private var groupModels: [FilterGroupModel]
    private let onFilterItemTapped: ((FilterItemModel)->Bool)?
    private let onApplyTapped: ([FilterGroupModel])->Void
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let topSeparatorView = UIView()
    
    private let filterGroupScrollView = UIScrollView()
    private let filterGroupStackView = UIStackView()
    private let filterGroupViews: [FilterGroupView]
    
    private let resetButton = UIButton()
    private let applyButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    
    // MARK: - Initializer
    init(
        groupModels: [FilterGroupModel],
        onFilterItemTapped: ((FilterItemModel)->Bool)? = nil,
        onApplyTapped: @escaping ([FilterGroupModel])->Void
    ) {
        self.groupModels = groupModels
        self.onFilterItemTapped = onFilterItemTapped
        self.onApplyTapped = onApplyTapped
        self.filterGroupViews = groupModels.map { group in
            FilterGroupView(filterGroup: group)
        }

        super.init(frame: .zero)

        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Bind
    private func bind() {
        for groupIndex in filterGroupViews.indices {
            filterGroupViews[groupIndex].itemTappedPublisher
                .sink { [weak self] itemIndex in
                    self?.didTapItem(groupIndex: groupIndex, itemIndex: itemIndex)
                }
                .store(in: &subscriptions)
        }
    }

    private func didTapItem(groupIndex: Int, itemIndex: Int) {
        let tappedItem = groupModels[groupIndex].items[itemIndex]
        if let onFilterItemTapped {
            guard onFilterItemTapped(tappedItem) else {
                return
            }
        }        
        let before = groupModels[groupIndex].items.map(\.isSelected)
        groupModels[groupIndex].didTap(itemAt: itemIndex)
        let after = groupModels[groupIndex].items.map(\.isSelected)

        filterGroupViews[groupIndex].update(
            filterGroup: groupModels[groupIndex],
            changed: Self.changedIndexPaths(before: before, after: after)
        )
    }

    private static func changedIndexPaths(before: [Bool], after: [Bool]) -> [IndexPath] {
        zip(before, after).enumerated().compactMap { index, pair in
            pair.0 != pair.1 ? IndexPath(row: index, section: 0) : nil
        }
    }
}

extension FilterBottomSheetView {
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        delegate?.dismiss()
    }
    
    @objc private func resetButtonTapped() {
        for groupIndex in groupModels.indices {
            let before = groupModels[groupIndex].items.map(\.isSelected)
            groupModels[groupIndex].reset()
            let after = groupModels[groupIndex].items.map(\.isSelected)

            filterGroupViews[groupIndex].update(
                filterGroup: groupModels[groupIndex],
                changed: Self.changedIndexPaths(before: before, after: after)
            )
        }
    }
    
    @objc private func applyButtonTapped() {
        onApplyTapped(groupModels)
        delegate?.dismiss()
    }
}

extension FilterBottomSheetView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        self.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.layer.cornerRadius = 32
        }
        
        titleLabel.do {
            $0.text = "필터"
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
            $0.textColor = UIColor.appColor(.new500)
        }
        
        closeButton.do {
            $0.setImage(.appImage(asset: .newCancel), for: .normal)
            $0.tintColor = UIColor.appColor(.neutral800)
        }
        
        [topSeparatorView, bottomSeparatorView].forEach {
            $0.do {
                $0.backgroundColor = UIColor.appColor(.neutral200)
            }
        }
        
        filterGroupScrollView.do {
//            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            $0.showsVerticalScrollIndicator = false
        }
        
        filterGroupStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 12
        }
        
        resetButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("초기화", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardSemiBold, size: 16),
                .foregroundColor : UIColor.appColor(.neutral600)
            ]))
            configuration.image = UIImage.appImage(asset: .refresh)
            configuration.imagePadding = 8
            configuration.imagePlacement = .trailing
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            $0.configuration = configuration
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        resetButton.setContentHuggingPriority(.required, for: .horizontal)
        resetButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        applyButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "적용하기",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 16),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 12
        }
    }
    
    private func setUpLayouts() {
        filterGroupViews.forEach {
            filterGroupStackView.addArrangedSubview($0)
        }
        [filterGroupStackView].forEach {
            filterGroupScrollView.addSubview($0)
        }
        [titleLabel, closeButton, topSeparatorView, filterGroupScrollView, resetButton, applyButton, bottomSeparatorView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        topSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        filterGroupScrollView.snp.makeConstraints {
            $0.top.equalTo(topSeparatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(filterGroupScrollView.contentLayoutGuide.snp.height).priority(.medium)
        }
        filterGroupStackView.snp.makeConstraints {
//            $0.edges.equalTo(filterGroupScrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(filterGroupScrollView.contentLayoutGuide)
            $0.top.bottom.equalTo(filterGroupScrollView.contentLayoutGuide).inset(12)
            $0.width.equalTo(filterGroupScrollView)
        }
        resetButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(filterGroupScrollView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        applyButton.snp.makeConstraints {
            $0.top.bottom.equalTo(resetButton)
            $0.leading.equalTo(resetButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-32)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(resetButton.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
