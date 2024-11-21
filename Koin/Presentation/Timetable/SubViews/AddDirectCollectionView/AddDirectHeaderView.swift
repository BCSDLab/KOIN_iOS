//
//  AddDirectHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectHeaderView: UICollectionReusableView {
    
    static let identifier = "AddDirectHeaderView"
    let classButtonPublisher = PassthroughSubject<Void, Never>()
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let addDirectLabel = UILabel().then {
        $0.text = "직접추가"
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.textColor = UIColor.appColor(.primary600)
    }
    
    private let classButton = UIButton().then {
        $0.setTitle("수업추가", for: .normal)
        $0.setTitleColor(UIColor.appColor(.primary500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let calendarView = ClassComponentView(text: "일정명", isPoint: true).then { _ in
    }
    
    private let professorNameView = ClassComponentView(text: "교수명", isPoint: false).then { _ in
    }
    
    private let selectTimeView = SelectTimeView(frame: .zero, size: .big).then { _ in
    }
    
    private let placeView = ClassComponentView(text: "장소", isPoint: false).then { _ in
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDirectHeaderView {
    @objc private func classButtonTapped() {
        classButtonPublisher.send()
    }
    @objc private func completeButtonTapped() {
        completeButtonPublisher.send()
    }
    
}
extension AddDirectHeaderView {
    private func setupViews() {
        self.backgroundColor = .systemBackground
        [addDirectLabel, classButton, completeButton, calendarView, professorNameView, selectTimeView, placeView].forEach {
            self.addSubview($0)
        }
        [calendarView, professorNameView, placeView].forEach {
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
        
        addDirectLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.width.equalTo(63)
            make.height.equalTo(29)
        }
        classButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(29)
        }
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(35)
            make.height.equalTo(29)
        }
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(addDirectLabel.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(35)
        }
        professorNameView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(calendarView)
        }
        selectTimeView.snp.makeConstraints { make in
            make.top.equalTo(professorNameView.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(calendarView)
        }
        placeView.snp.makeConstraints { make in
            make.top.equalTo(selectTimeView.snp.bottom).offset(8)
            make.leading.trailing.height.equalTo(calendarView)
        }
    }
}
