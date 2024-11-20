//
//  SelectTimeView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import UIKit

final class SelectTimeView: UIView {
    
    private let size: Size
    
    enum Size {
        case small
        case big
    }
    
    private let timeLabel = PointLabel(text: "시간").then { _ in
    }
    
    private let selectWeekButton = UIButton().then { _ in
    }
    
    private let startTimeButton = UIButton().then { _ in
    }
    
    private let separateLabel = UILabel().then {
        $0.text = "~"
        $0.textAlignment = .center
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let endTimeButton = UIButton().then { _ in
    }
    
    init(frame: CGRect, size: Size) {
        self.size = size // 전달받은 size 값을 초기화
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SelectTimeView {
    
}

extension SelectTimeView {
    private func setupViews() {
        [timeLabel, selectWeekButton, startTimeButton, separateLabel, endTimeButton].forEach {
            self.addSubview($0)
        }
        [selectWeekButton, startTimeButton, endTimeButton].forEach {
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(13)
            make.width.equalTo(21)
            make.centerY.equalTo(self.snp.centerY)
        }
        selectWeekButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(timeLabel.snp.trailing).offset(self.size == .big ? 25.25 : 18.5)
            make.width.equalTo(74)
            make.height.equalTo(35)
        }
        startTimeButton.snp.makeConstraints { make in
            make.top.width.height.equalTo(selectWeekButton)
            make.leading.equalTo(selectWeekButton.snp.trailing).offset(self.size == .big ? 11.25 : 4.5)
        }
        endTimeButton.snp.makeConstraints { make in
            make.top.width.height.equalTo(selectWeekButton)
            make.trailing.equalTo(self.snp.trailing)
        }
        separateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(startTimeButton.snp.centerY)
            make.leading.equalTo(startTimeButton.snp.trailing)
            make.trailing.equalTo(endTimeButton.snp.leading)
        }
    }
}
