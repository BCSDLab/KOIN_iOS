//
//  ShopInfoTableViewOriginsCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopInfoTableViewOriginsCell: UITableViewCell {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.contentMode = .center
        $0.font = .appFont(.pretendardSemiBold, size: 15)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let originsLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
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
    
    func configure(title: String, origins: [Origin]) {
        titleLabel.text = title
        originsLabel.setLineHeight(lineHeight: 1.40, text: origins // MARK: - 행간 140으로 임의 조정
            .map {
                return "\($0.ingredient)(\($0.origin))"
            }
            .joined(separator: ", "))
    }
}

extension ShopInfoTableViewOriginsCell {
    
    private func setUpLayout() {
        [titleLabel, originsLabel, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        originsLabel.snp.makeConstraints {
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
