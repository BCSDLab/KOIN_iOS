//
//  DatePickerDropdownView.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import UIKit

final class DatePickerDropdownView: UIView {
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
        $0.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        $0.maximumDate = Date()
    }
    
    var onDateSelected: ((Date) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 114)
        ])
        
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
    
    
    func confirmSelection() {
        
        onDateSelected?(datePicker.date)  // 현재 보이는 날짜로 설정
    }
}
