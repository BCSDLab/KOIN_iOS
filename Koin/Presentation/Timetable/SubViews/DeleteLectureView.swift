//
//  DeleteLectureView.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine
import UIKit

final class DeleteLectureView: UIView {
    
    let deleteButtonPublisher = PassthroughSubject<LectureData, Never>()
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    var info: LectureData?
    
    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 18)
        $0.setTitleColor(UIColor.appColor(.danger700), for: .normal)
    }
    private let infoLabel = UILabel().then {
        $0.text = "수업상세"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let classTitleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let professorNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let classTimeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let gradeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let classCodeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    init() {
        super.init(frame: .zero)
        configureView()
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func completeButtonTapped() {
        completeButtonPublisher.send()
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonPublisher.send(info ?? LectureData(id: 0, name: "", professor: "", classTime: [], grades: ""))
    }
    
    func configure(lecture: LectureData) {
        classTitleLabel.text = lecture.name
        professorNameLabel.text = lecture.professor
        classTimeLabel.text = "\(lecture.classTime)"
        gradeLabel.text = "\(lecture.grades)학점"
        info = lecture
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DeleteLectureView {
    private func setUpLayouts() {
        [deleteButton, infoLabel, completeButton, separateView, classTitleLabel, professorNameLabel, classTimeLabel, gradeLabel, classCodeLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.width.equalTo(32)
            make.height.equalTo(29)
        }
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(32)
            make.height.equalTo(29)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.centerX.equalTo(self.snp.centerX)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(12)
            make.leading.equalTo(deleteButton.snp.leading)
            make.trailing.equalTo(completeButton.snp.trailing)
            make.height.equalTo(1)
        }
        classTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.top).offset(13)
            make.leading.equalTo(deleteButton)
        }
        professorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(classTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(deleteButton)
        }
        classTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(professorNameLabel.snp.bottom).offset(7)
            make.leading.equalTo(deleteButton)
        }
        gradeLabel.snp.makeConstraints { make in
            make.top.equalTo(classTimeLabel.snp.bottom).offset(5)
            make.leading.equalTo(deleteButton)
        }
        classCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(classTimeLabel.snp.bottom).offset(5)
            make.leading.equalTo(gradeLabel.snp.trailing).offset(10)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.backgroundColor = .systemBackground
    }
}
