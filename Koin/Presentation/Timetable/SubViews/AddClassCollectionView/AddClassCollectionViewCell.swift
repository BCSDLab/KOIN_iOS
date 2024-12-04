//
//  AddClassCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

final class AddClassCollectionViewCell: UICollectionViewCell {
    
    var cancellables = Set<AnyCancellable>()
    let modifyClassButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let classTitleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let professorNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let classTimeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let gradeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let classCodeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let modifyClassButton = UIButton().then { _ in
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        modifyClassButton.addTarget(self, action: #selector(modifyClassButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    func configure(lecture: SemesterLecture, isAdded: Bool) {
        classTitleLabel.text = lecture.name
        professorNameLabel.text = lecture.professor
        classTimeLabel.text = lecture.classTime.timeLabelText()
        gradeLabel.text = "\(lecture.grades)학점"
        classCodeLabel.text = lecture.code
        
        modifyClassButton.setImage(UIImage.appImage(asset: !isAdded ? .plusCircle : .minusCircle), for: .normal)
    }
}

extension AddClassCollectionViewCell {
    @objc private func modifyClassButtonTapped() {
        modifyClassButtonPublisher.send()
       
    }
}
extension AddClassCollectionViewCell {
    private func setUpLayouts() {
        [classTitleLabel, professorNameLabel, classTimeLabel, gradeLabel, classCodeLabel, modifyClassButton, separateView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        classTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(4)
            make.leading.equalToSuperview()
        }
        professorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(classTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
        }
        classTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(professorNameLabel.snp.bottom).offset(7)
            make.leading.equalToSuperview()
        }
        gradeLabel.snp.makeConstraints { make in
            make.top.equalTo(classTimeLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
        }
        classCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(classTimeLabel.snp.bottom).offset(5)
            make.leading.equalTo(gradeLabel.snp.trailing).offset(10)
        }
        modifyClassButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-7)
            make.width.height.equalTo(24)
        }
        separateView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
