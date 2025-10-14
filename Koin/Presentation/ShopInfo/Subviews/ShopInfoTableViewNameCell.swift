//
//  ShopInfoTableViewNameCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopInfoTableViewNameCell: UITableViewCell {
    
    // MARK: - Components
    private let titleLabel = UILabel().then {
        $0.contentMode = .center
        $0.font = .appFont(.pretendardSemiBold, size: 15)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .equalSpacing
    }
    private let nameTitleLabel = UILabel().then { $0.text = "상호명" }
    private let addressTitleLabel = UILabel().then { $0.text = "주소" }
    private let runTimeTitleLabel = UILabel().then { $0.text = "운영시간" }
    private let closedDaysTitleLabel = UILabel().then { $0.text = "휴무일" }
    private let phoneTitleLabel = UILabel().then { $0.text = "전화번호" }
    
    private let valueStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .equalSpacing
    }
    private let nameValueLabel = UILabel()
    private let addressValueLabel = UILabel()
    private let runTimeValueLabel = UILabel()
    private let closedDaysValueLabel = UILabel()
    private let phoneValueLabel = UILabel()
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
    
    func configure(title: String, name: String, address: String, openTime: String, closeTime: String, closedDays: [ClosedDay], phone: String) {
        titleLabel.text = title
        nameValueLabel.text = name
        addressValueLabel.text = address
        runTimeValueLabel.text = "\(openTime) ~ \(closeTime)"
        configureClosedDays(closedDays: closedDays)
        phoneValueLabel.text = phone
    }
}

extension ShopInfoTableViewNameCell {
    
    private func configureClosedDays(closedDays: [ClosedDay]) {
        if closedDays.isEmpty {
            closedDaysValueLabel.text = "연중무휴"
        }
        else {
            closedDaysValueLabel.text = "매주 " + closedDays
                .map { toKorean(closedDay: $0) }
                .joined(separator: ", ")
        }   
    }
    
    private func toKorean(closedDay: ClosedDay) -> String {
        switch closedDay {
        case .monday: "월요일"
        case .tuesday: "화요일"
        case .wednesday: "수요일"
        case .thursday: "목요일"
        case .friday: "금요일"
        case .saturday: "토요일"
        case .sunday: "일요일"
        }
    }
}

extension ShopInfoTableViewNameCell {
    
    private func setUpLabels() {
        [nameTitleLabel, addressTitleLabel, runTimeTitleLabel, closedDaysTitleLabel, phoneTitleLabel,
         nameValueLabel, addressValueLabel, runTimeValueLabel, closedDaysValueLabel, phoneValueLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.textAlignment = .left
            $0.numberOfLines = 1
        }
    }
    private func setUpLayout() {
        [nameTitleLabel, addressTitleLabel, runTimeTitleLabel, closedDaysTitleLabel, phoneTitleLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [nameValueLabel, addressValueLabel, runTimeValueLabel, closedDaysValueLabel, phoneValueLabel].forEach {
             valueStackView.addArrangedSubview($0)
        }
        [titleLabel, titleStackView, valueStackView, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        [nameTitleLabel, addressTitleLabel, runTimeTitleLabel, closedDaysTitleLabel, phoneTitleLabel,
         nameValueLabel, addressValueLabel, runTimeValueLabel, closedDaysValueLabel, phoneValueLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(22)
            }
        }
        titleStackView.snp.makeConstraints {
            $0.height.equalTo(142)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(runTimeTitleLabel.intrinsicContentSize.width)
            $0.bottom.equalToSuperview().offset(-18)
        }
        valueStackView.snp.makeConstraints {
            $0.height.equalTo(142)
            $0.top.equalTo(titleStackView.snp.top)
            $0.leading.equalTo(titleStackView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-22)
            $0.bottom.equalTo(titleStackView.snp.bottom)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
        
    private func configureView() {
        setUpLabels()
        setUpLayout()
        setUpConstraints()
    }
}
