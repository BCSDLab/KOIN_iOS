//
//  DatePickerDropdownView.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import UIKit
import Combine
import SnapKit

final class DatePickerDropdownView: UIView {
    
    // MARK: - Properties
    let valueChangedPublisher = PassthroughSubject<Void, Never>()
    let dismissDropdownPublisher = PassthroughSubject<Void, Never>()
    
    var dateValue: Date {
        get { return datePicker.date }
        set { datePicker.date = newValue }
    }
    
    // MARK: - UI Components
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
        $0.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        $0.maximumDate = Date()
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    private let resetButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(
            string: "초기화",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.primary600)
            ]), for: .normal)
    }
    private let applyButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(
            string: "확인",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.primary600)
            ]), for: .normal)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTargets()
        datePicker.addTarget(self, action: #selector(datePickerValueChagned), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DatePickerDropdownView {
    
    private func setAddTargets() {
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func resetButtonTapped() {
        dateValue = Date()
        datePickerValueChagned()
    }
    
    @objc private func applyButtonTapped() {
        dismissDropdownPublisher.send()
    }
}

extension DatePickerDropdownView {
    
    private func setUpLayouts() {
        [datePicker, separatorView, applyButton, resetButton].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        datePicker.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(114)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        applyButton.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().offset(-40)
            $0.bottom.equalToSuperview().offset(-14)
            $0.height.equalTo(22)
        }
        resetButton.snp.makeConstraints {
            $0.height.centerY.equalTo(applyButton)
            $0.trailing.equalTo(applyButton.snp.leading).offset(-16)
        }
    }
    
    private func configureView(){
        setUpLayouts()
        setUpConstraints()
        
        DispatchQueue.main.async {
            self.updatePickerTextColor()
        }
    }
    
    private func updatePickerTextColor() {
        for subview in datePicker.subviews {
            for nestedSubview in subview.subviews {
                if let pickerLabel = nestedSubview as? UILabel {
                    pickerLabel.textColor = .blue
                    pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                }
            }
        }
    }
    
    @objc private func datePickerValueChagned() {
        valueChangedPublisher.send()
    }
}
