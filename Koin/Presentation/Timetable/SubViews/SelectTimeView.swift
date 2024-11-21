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
    
    private let selectWeekButton = UIButton().then {
            $0.setTitle("월요일", for: .normal) // 기본값 설정
            $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 12)
        }
        
        private let startTimeButton = UIButton().then {
            $0.setTitle("09:00", for: .normal) // 기본값 설정
            $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 12)
        }
        
        private let separateLabel = UILabel().then {
            $0.text = "~"
            $0.textAlignment = .center
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        }
        
        private let endTimeButton = UIButton().then {
            $0.setTitle("10:00", for: .normal) // 기본값 설정
            $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 12)
        }
    
    init(frame: CGRect, size: Size) {
        self.size = size // 전달받은 size 값을 초기화
        super.init(frame: frame)
        setupViews()
        selectWeekButton.addTarget(self, action: #selector(didTapSelectWeek), for: .touchUpInside)
              startTimeButton.addTarget(self, action: #selector(didTapStartTime), for: .touchUpInside)
              endTimeButton.addTarget(self, action: #selector(didTapEndTime), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SelectTimeView {
    @objc private func didTapSelectWeek() {
        let alertController = UIAlertController(title: "요일 선택", message: nil, preferredStyle: .actionSheet)
        let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일"]
        
        weekdays.forEach { day in
            alertController.addAction(UIAlertAction(title: day, style: .default, handler: { _ in
                self.selectWeekButton.setTitle(day, for: .normal)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapStartTime() {
        showTimePicker(for: startTimeButton)
    }
    
    @objc private func didTapEndTime() {
        showTimePicker(for: endTimeButton)
    }
    
    private func showTimePicker(for button: UIButton) {
        let alertController = UIAlertController(title: "시간 선택", message: nil, preferredStyle: .actionSheet)
        let times = generateTimeIntervals(startHour: 9, endHour: 24, intervalMinutes: 30)
        
        times.forEach { time in
            alertController.addAction(UIAlertAction(title: time, style: .default, handler: { _ in
                button.setTitle(time, for: .normal)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func generateTimeIntervals(startHour: Int, endHour: Int, intervalMinutes: Int) -> [String] {
        var times: [String] = []
        for hour in startHour..<endHour {
            for minute in stride(from: 0, to: 60, by: intervalMinutes) {
                let time = String(format: "%02d:%02d", hour, minute)
                times.append(time)
            }
        }
        return times
    }
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
