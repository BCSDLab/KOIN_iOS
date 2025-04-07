//
//  CalendarCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 4/6/24.
//

import SnapKit
import UIKit

final class CalendarCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let weekLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let dayLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let todayCircleView = UIView().then { totalView in
        let circleView = UIView().then {
            $0.layer.cornerRadius = 14
            $0.backgroundColor = UIColor.clear
            $0.layer.borderColor = UIColor.appColor(.primary500).cgColor
            $0.layer.borderWidth = 1
        }
        
        let underlineView = UIView().then {
            $0.backgroundColor = UIColor.appColor(.primary500)
            $0.layer.cornerRadius = 4
        }
        
        [circleView, underlineView].forEach{
            totalView.addSubview($0)
        }
        
        circleView.snp.makeConstraints {
            $0.width.height.equalTo(28)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(0)
        }
        
        underlineView.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(2)
            $0.centerX.equalTo(circleView)
            $0.top.equalTo(circleView.snp.bottom).offset(4)
        }
        
        totalView.backgroundColor = .clear
    }
    
    private let selectedCircleView = UIView().then {
        $0.layer.cornerRadius = 14
        $0.backgroundColor = UIColor.appColor(.primary500)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(date: CalendarDate, indexPath: IndexPath) {
        weekLabel.text = date.date.dayOfWeek()
        dayLabel.text = date.date.dayOfMonth()
        switch indexPath.row {
        case 0,1,2: 
            dayLabel.textColor = UIColor.appColor(.neutral500)
            todayCircleView.isHidden = true
        case 3:
            dayLabel.textColor = date.isInitDate ? UIColor.appColor(.neutral0) : UIColor.appColor(.primary500)
        default:
            dayLabel.textColor = UIColor.appColor(.neutral800)
            todayCircleView.isHidden = true
        }
        selectedCircleView.isHidden = !date.isInitDate
        if date.isInitDate { dayLabel.textColor = UIColor.appColor(.neutral0) }
    }
    
    func changeSelectedCell(isSelected: Bool, indexPath: IndexPath) {
        selectedCircleView.isHidden = !isSelected
        dayLabel.textColor = isSelected ? UIColor.appColor(.neutral0) : indexPath.row >= 3 ? UIColor.appColor(.neutral800) : UIColor.appColor(.neutral500)
        if indexPath.row == 3 && !isSelected {
            dayLabel.textColor = UIColor.appColor(.primary500)
        }
    }
}

extension CalendarCollectionViewCell {
    private func setUpLayouts() {
        [weekLabel, todayCircleView, selectedCircleView, dayLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        weekLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.centerX.equalTo(self.snp.centerX)
        }
        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(weekLabel.snp.bottom).offset(12)
            make.centerX.equalTo(weekLabel.snp.centerX)
        }
        todayCircleView.snp.makeConstraints { make in
            make.centerX.equalTo(dayLabel.snp.centerX)
            make.top.equalTo(selectedCircleView)
            make.width.equalTo(28)
            make.height.equalTo(34)
        }
        selectedCircleView.snp.makeConstraints { make in
            make.centerX.equalTo(dayLabel.snp.centerX)
            make.centerY.equalTo(dayLabel.snp.centerY)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

