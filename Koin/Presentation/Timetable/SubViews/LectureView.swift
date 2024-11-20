//
//  LectureView.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class LectureView: UIView {
    
    private(set) var id: Int
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800)
    }
    private let lectureNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.numberOfLines = 0
    }
    private let professorNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.numberOfLines = 0
    }
    init(id: Int, lectureName: String, professorName: String, color: UIColor) {
        self.id = id
        super.init(frame: .zero)
        lectureNameLabel.backgroundColor = color
        lectureNameLabel.text = lectureName
        professorNameLabel.backgroundColor = color
        self.backgroundColor = color
        professorNameLabel.text = professorName
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
