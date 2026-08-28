//
//  FilterGroupView.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class FilterGroupView: UIView {
    
    // MARK: - Publisher
    var itemTappedPublisher: AnyPublisher<Int, Never> {
        filterGroupCollectionView.itemTappedPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let filterGroupCollectionView: FilterGroupCollectionView
    private let separatorView = UIView()
    
    // MARK: - Initializer
    init(filterGroup: FilterGroupModel) {
        self.filterGroupCollectionView = FilterGroupCollectionView(filterGroup: filterGroup)
        super.init(frame: .zero)
        
        titleLabel.text = filterGroup.title
        descriptionLabel.text = filterGroup.description
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(filterGroup: FilterGroupModel, changed: [IndexPath]) {
        filterGroupCollectionView.update(filterGroup: filterGroup, changed: changed)
    }
}

extension FilterGroupView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        descriptionLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, filterGroupCollectionView, separatorView].forEach {
            addSubview($0)
        }
        if descriptionLabel.text != nil {
            addSubview(descriptionLabel)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.leading.top.equalToSuperview()
        }
        if descriptionLabel.text != nil {
            descriptionLabel.snp.makeConstraints {
                $0.height.equalTo(19)
                $0.centerY.equalTo(titleLabel)
                $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            }
        }
        filterGroupCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(filterGroupCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
