//
//  LectureView.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit


final class LectureView: UIView {
    
    private(set) var info: LectureData
    
    let separateView = UIView().then { _ in
    }
    
    let lectureNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.numberOfLines = 0
    }
    let professorNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.numberOfLines = 0
    }
    init(info: LectureData, color: UIColor) {
        self.info = info
        super.init(frame: .zero)
        lectureNameLabel.text = info.name
        professorNameLabel.text = info.professor
        setupLayouts()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layouts
    private func setupLayouts() {
        addSubview(separateView)
        addSubview(lectureNameLabel)
        addSubview(professorNameLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        separateView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        lectureNameLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
        }
        professorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(lectureNameLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
}
