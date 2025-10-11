//
//  OrderCartSegmentedControlCell.swift
//  koin
//
//  Created by 홍기정 on 9/30/25.
//

import UIKit

final class OrderCartSegmentedControlCell: UITableViewCell {
    
    // MARK: - Properties
    
    // MARK: - Components
    private let segmentedControl = OrderCartSegmentedControl()
    private let descriptionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    private let descriptionImageView = UIImageView(image: .appImage(asset: .incorrectInfo)?.withRenderingMode(.alwaysTemplate).withTintColor(.appColor(.new500)))
    private let descriptionLabel = UILabel().then {
        $0.text = "이 가게는 포장주문만 가능해요"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.new500)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool) {
        segmentedControl.configure(isDeliveryAvailable: isDeliveryAvailable, isTakeOutAvailable: isTakeOutAvailable)
        
        if isDeliveryAvailable && isTakeOutAvailable {
            descriptionImageView.snp.removeConstraints()
            descriptionStackView.snp.updateConstraints {
                $0.top.equalTo(segmentedControl.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
        }
        else {
            if !isDeliveryAvailable {
                descriptionLabel.text = "이 가게는 포장주문만 가능해요"
            } else if !isTakeOutAvailable {
                descriptionLabel.text = "이 가게는 배달주문만 가능해요"
            }
        }
    }
}

extension OrderCartSegmentedControlCell {
    
    private func setUpLayout() {
        [descriptionImageView, descriptionLabel].forEach {
            descriptionStackView.addArrangedSubview($0)
        }
        
        [segmentedControl, descriptionStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        segmentedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(46)
        }
        descriptionImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        descriptionStackView.snp.makeConstraints {
            $0.leading.equalTo(segmentedControl).offset(2)
            $0.top.equalTo(segmentedControl.snp.bottom).offset(6)
            $0.height.equalTo(19)
            $0.bottom.equalToSuperview()
        }
    }
    private func configureView() {
        backgroundColor = .clear
        backgroundView = .none
        setUpLayout()
        setUpConstraints()
    }
}
