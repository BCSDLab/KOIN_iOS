//
//  CallVanPostDateView.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanPostDateView: UIView {
    
    // MARK: - Properties
    let dateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    /// 사용자 조작(휠·초기화)일 때만 발행
    let dateChangedPublisher = PassthroughSubject<Date, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    var date: Date {
        return dateDropDownView.date
    }
    
    // MARK: - Dropdown
    var dropdownTrigger: UIView { dateButton }
    var dropdownContentView: UIView & KoinDropdownContentView { dateDropDownView }

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateButton = UIButton()
    private let dateLabel = UILabel()
    private let downArrowImageView = UIImageView()
    private let dateDropDownView: NewKoinPickerDropDownView
    
    // MARK: - Initializer
    init(now: Date) {
        self.dateDropDownView = NewKoinPickerDropDownView(configuration: .callVanDate(now: now))
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    /// 이벤트 없음. 범위로 보정된 값(date)으로 라벨 갱신
    func setDate(_ date: Date) {
        dateDropDownView.setDate(date)
        updateDateLabel(dateDropDownView.date)
    }
}

extension CallVanPostDateView {
    
    private func bind() {
        dateDropDownView.datePublisher.sink { [weak self] date in
            self?.updateDateLabel(date)
            self?.dateChangedPublisher.send(date)
        }.store(in: &subscriptions)
    }
    
    private func updateDateLabel(_ date: Date) {
        dateLabel.text = date.string(with: .yearMonthDay)
    }
}

extension CallVanPostDateView {
    
    private func setAddTargets() {
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dateButtonTapped() {
        dateButtonTappedPublisher.send()
    }
}

extension CallVanPostDateView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.text = "출발일"
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.new500)
        }
        descriptionLabel.do {
            $0.text = "출발 날짜를 선택해주세요."
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        dateButton.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
        dateLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        downArrowImageView.do {
            $0.image = UIImage.appImage(asset: .arrowDown)
        }
        
        dateDropDownView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, descriptionLabel, dateButton, dateLabel, downArrowImageView].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(titleLabel)
        }
        dateButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateButton)
            $0.leading.equalTo(dateButton).offset(12)
            $0.trailing.lessThanOrEqualTo(downArrowImageView.snp.leading).offset(-12)
        }
        downArrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(dateButton)
            $0.trailing.equalTo(dateButton).offset(-12)
        }
    }
}
