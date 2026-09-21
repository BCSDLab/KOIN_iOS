//
//  CallVanPostTimeView.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanPostTimeView: UIView {
    
    // MARK: - Properteis
    let timeButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let timeChangedPublisher = PassthroughSubject<Date, Never>()
    
    private var subscriptions: Set<AnyCancellable> = []
    private let formatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    // MARK: - Dropdown
    var dropdownTrigger: UIView { timeButton }
    var dropdownContentView: UIView & KoinDropdownContentView { timeDropDownView }
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let timeButton = UIButton()
    private let amPmLabel = UILabel()
    private let separatorView = UIView()
    private let timeLabel = UILabel()
    private let timeDropDownView = KoinPickerDropDownView(delegate: KoinPickerDropDownViewTimeDelegate())
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public
    func update(_ date: Date) {
        timeDropDownView.reset(initialDate: date)
    }
}

extension CallVanPostTimeView {
    
    private func bind() {
        timeDropDownView.selectedItemPublisher.sink { [weak self] selectedItems in
            let amPm = selectedItems[0] == "AM" ? "오전" : "오후"
            var hour = selectedItems[1]
            if hour.count == 1 {
                hour = "0" + hour
            }
            let minute = selectedItems[2]
            
            self?.amPmLabel.text = amPm
            self?.timeLabel.text =  "\(hour):\(minute)"
            
            self?.formatter.dateFormat = "a hh:mm"
            if let date = self?.formatter.date(from: "\(amPm) \(hour):\(minute)") {
                self?.timeChangedPublisher.send(date)
            }
        }.store(in: &subscriptions)
        
    }
}

extension CallVanPostTimeView {
    
    private func setAddTargets() {
        timeButton.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func timeButtonTapped() {
        timeButtonTappedPublisher.send()
    }
}

extension CallVanPostTimeView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        timeDropDownView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
        titleLabel.do {
            $0.text = "출발 시각"
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.new500)
        }
        descriptionLabel.do {
            $0.text = "출발 시각을 선택해주세요."
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        timeButton.do {
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 4
        }
        amPmLabel.do {
            $0.text = "오전"
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.textAlignment = .center
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral400)
        }
        timeLabel.do {
            $0.text = "00:00"
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, descriptionLabel, timeButton, amPmLabel, separatorView, timeLabel].forEach {
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
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        timeButton.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        amPmLabel.snp.makeConstraints {
            $0.width.equalTo(38)
            $0.leading.centerY.equalTo(timeButton)
        }
        separatorView.snp.makeConstraints {
            $0.top.bottom.equalTo(timeButton)
            $0.width.equalTo(1)
            $0.leading.equalTo(amPmLabel.snp.trailing)
        }
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(timeButton)
            $0.leading.equalTo(separatorView.snp.trailing).offset(16)
        }
    }
}
