//
//  LectureView.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class LectureView: UIView {
    // MARK: - Properties
    private(set) var info: LectureData
    private let bodyColor: UIColor
    private let headerColor: UIColor

    // MARK: - UI Components
    let separateView = UIView()
    let lectureNameLabel = UILabel()
    let professorNameLabel = UILabel()

    init(info: LectureData, color: UIColor, headerColor: UIColor) {
        self.info = info
        self.bodyColor = color
        self.headerColor = headerColor
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = bodyColor
        clipsToBounds = true
        separateView.backgroundColor = headerColor
        configureLabel(lectureNameLabel, text: info.name, size: 12)
        configureLabel(professorNameLabel, text: info.professor, size: 10)
    }

    private func configureLabel(_ label: UILabel, text: String, size: Int) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = CGFloat(size) * 1.6
        paragraph.maximumLineHeight = CGFloat(size) * 1.6
        paragraph.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.appFont(.pretendardRegular, size: size),
            .foregroundColor: UIColor.appColor(.neutral800),
            .paragraphStyle: paragraph
        ])
    }

    private func setUpLayouts() {
        [separateView, lectureNameLabel, professorNameLabel].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        separateView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        lectureNameLabel.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        professorNameLabel.snp.makeConstraints {
            $0.top.equalTo(lectureNameLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
