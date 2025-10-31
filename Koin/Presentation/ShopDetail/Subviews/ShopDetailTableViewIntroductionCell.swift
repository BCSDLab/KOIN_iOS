//
//  ShopDetailTableViewIntroductionCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopDetailTableViewIntroductionCell: UITableViewCell {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.contentMode = .center
        $0.font = .appFont(.pretendardSemiBold, size: 15)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let introductionLabel = UILabel().then {
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral50)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, introduction: String) {
        titleLabel.text = title
        introductionLabel.setLineHeight(lineHeight: 1.40, text: introduction) // MARK: - 행간 140으로 임의 조정
    }
}

extension ShopDetailTableViewIntroductionCell {
    
    private func setUpLayout() {
        [titleLabel, introductionLabel, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        introductionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(-8)  // FIXME: - 행간으로 인한 오차 offset으로 임의 조정
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-18)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
