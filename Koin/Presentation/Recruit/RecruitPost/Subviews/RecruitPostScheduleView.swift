//
//  RecruitPostScheduleView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostScheduleView: UIView {
    
    // MARK: - Properties
    let startDateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let endDateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deadlineDateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    private let formatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.dateFormat = "yyyy.MM.dd"
    }
    
    // MARK: - UI Components
    private let headerView = RecruitPostSectionHeaderView(title: "일정", isRequired: true)
    
    private let activityPeriodLabel = UILabel()
    private let startDateButton = UIButton()
    private let startDateLabel = UILabel()
    private let dashLabel = UILabel()
    private let endDateButton = UIButton()
    private let endDateLabel = UILabel()
    private let deadlineLabel = UILabel()
    private let deadlineDateButton = UIButton()
    private let deadlineDateLabel = UILabel()
    
    // MARK: - Dropdown
    let activityPeriodDropdownAnchor = UIView()
    let deadlineDateDropdownAnchor = UIView()
    
    let startDateDropdownContentView = KoinPickerDropDownView(
        delegate: KoinPickerDropDownViewDateDelegate(range: 0..<365) // TODO: range 대신 Date 로 리팩토링
    ).then {
        $0.reset(initialDate: Date())
        $0.backgroundColor = .appColor(.neutral0)
    }
    let endDateDropdownContentView = KoinPickerDropDownView(
        delegate: KoinPickerDropDownViewDateDelegate(range: 0..<365)
    ).then {
        $0.reset(initialDate: Date())
        $0.backgroundColor = .appColor(.neutral0)
    }
    let deadlineDateDropdownContentView = KoinPickerDropDownView(
        delegate: KoinPickerDropDownViewDateDelegate(range: 0..<365)
    ).then {
        $0.reset(initialDate: Date())
        $0.backgroundColor = .appColor(.neutral0)
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        startDateDropdownContentView.reset(initialDate: Date())
        endDateDropdownContentView.reset(initialDate: Date())
        deadlineDateDropdownContentView.reset(initialDate: Date())

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(
        startDate: Date? = nil,
        endDate: Date? = nil,
        deadlineDate: Date? = nil
    ) {
        if let startDate {
            startDateLabel.text = formatter.string(from: startDate)
            startDateDropdownContentView.reset(initialDate: startDate)
        }
        if let endDate {
            endDateLabel.text = formatter.string(from: endDate)
            endDateDropdownContentView.reset(initialDate: endDate)
        }
        if let deadlineDate {
            deadlineDateLabel.text = formatter.string(from: deadlineDate)
            deadlineDateDropdownContentView.reset(initialDate: deadlineDate)
        }
    }
}

extension RecruitPostScheduleView {
    private func setAddTargets() {
        startDateButton.addTarget(self, action: #selector(startDateButtonTapped), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(endDateButtonTapped), for: .touchUpInside)
        deadlineDateButton.addTarget(self, action: #selector(deadlineDateButtonTapped), for: .touchUpInside)
    }
    @objc private func startDateButtonTapped() {
        startDateButtonTappedPublisher.send()
    }
    @objc private func endDateButtonTapped() {
        endDateButtonTappedPublisher.send()
    }
    @objc private func deadlineDateButtonTapped() {
        deadlineDateButtonTappedPublisher.send()
    }
}

extension RecruitPostScheduleView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        activityPeriodLabel.do {
            $0.text = "활동기간"
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        deadlineLabel.do {
            $0.text = "마감일"
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        [startDateButton, endDateButton, deadlineDateButton].forEach {
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .appColor(.neutral0)
        }
        [startDateLabel, endDateLabel, deadlineDateLabel].forEach { label in
            label.do {
                $0.font = UIFont.appFont(.pretendardRegular, size: 12)
                $0.textAlignment = .center
                $0.textColor = .appColor(.neutral600)
            }
        }
        startDateLabel.text = "시작일"
        endDateLabel.text = "종료일"
        deadlineDateLabel.text = "마감일"
        
        dashLabel.do {
            $0.text = "-"
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 16)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.textAlignment = .center
        }
        [activityPeriodDropdownAnchor, deadlineDateDropdownAnchor].forEach {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = false
        }
        [startDateDropdownContentView, endDateDropdownContentView, deadlineDateDropdownContentView].forEach {
            $0.layer.cornerRadius = 16
        }
    }
    
    private func setUpLayouts() {
        [headerView,
         activityPeriodLabel,
         activityPeriodDropdownAnchor, startDateButton, startDateLabel, dashLabel, endDateButton, endDateLabel,
         deadlineLabel,
         deadlineDateDropdownAnchor, deadlineDateButton, deadlineDateLabel
        ].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        activityPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        activityPeriodDropdownAnchor.snp.makeConstraints {
            $0.top.bottom.equalTo(startDateButton)
            $0.leading.trailing.equalToSuperview()
        }
        startDateButton.snp.makeConstraints {
            $0.top.equalTo(activityPeriodLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.height.equalTo(35)
        }
        startDateLabel.snp.makeConstraints {
            $0.edges.equalTo(startDateButton)
        }
        dashLabel.snp.makeConstraints {
            $0.centerY.equalTo(startDateButton)
            $0.centerX.equalToSuperview()
            $0.leading.equalTo(startDateButton.snp.trailing)
            $0.trailing.equalTo(endDateButton.snp.leading)
            $0.width.equalTo(48)
        }
        endDateButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.height.equalTo(startDateButton)
            $0.height.equalTo(startDateButton)
        }
        endDateLabel.snp.makeConstraints {
            $0.edges.equalTo(endDateButton)
        }
        
        deadlineLabel.snp.makeConstraints {
            $0.top.equalTo(startDateButton.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        deadlineDateDropdownAnchor.snp.makeConstraints {
            $0.top.bottom.equalTo(deadlineDateButton)
            $0.leading.trailing.equalToSuperview()
        }
        deadlineDateButton.snp.makeConstraints {
            $0.top.equalTo(deadlineLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(startDateButton)
            $0.bottom.equalToSuperview()
        }
        deadlineDateLabel.snp.makeConstraints {
            $0.edges.equalTo(deadlineDateButton)
        }
    }
}
