//
//  AddClassCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

final class AddClassCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let modifyClassButtonPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let selectionView = UIView()
    private let classTitleLabel = UILabel()
    private let professorNameLabel = UILabel()
    private let classTimeLabel = UILabel()
    private let metadataStackView = UIStackView()
    private let yearLabel = UILabel()
    private let gradeLabel = UILabel()
    private let lectureClassLabel = UILabel()
    private let classCodeLabel = UILabel()
    private let modifyClassButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        modifyClassButton.addTarget(self, action: #selector(modifyTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    func configure(lecture: SemesterLecture, isAdded: Bool, isPreviewing: Bool) {
        classTitleLabel.text = lecture.name
        professorNameLabel.text = lecture.professor
        classTimeLabel.text = lecture.classTime.timeLabelText()
        setMetadata(lecture.target, on: yearLabel)
        setMetadata(lecture.grades.isEmpty ? "" : "\(lecture.grades)학점", on: gradeLabel)
        setMetadata(lecture.lectureClass, on: lectureClassLabel)
        setMetadata(lecture.code, on: classCodeLabel)
        selectionView.isHidden = !isPreviewing
        modifyClassButton.setImage(.appImage(asset: isAdded ? .timetableMinusDanger : .timetablePlusNew500), for: .normal)
        modifyClassButton.accessibilityLabel = isAdded ? "강의 삭제" : "강의 추가"
    }

    private func setMetadata(_ text: String, on label: UILabel) {
        label.text = text
        label.isHidden = text.isEmpty
    }

    @objc private func modifyTapped() { modifyClassButtonPublisher.send() }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        selectionView.backgroundColor = .appColor(.neutral100)
        selectionView.layer.cornerRadius = 8
        selectionView.isUserInteractionEnabled = false
        classTitleLabel.font = .appFont(.pretendardSemiBold, size: 12)
        [classTitleLabel, professorNameLabel, classTimeLabel].forEach {
            $0.textColor = .appColor(.neutral800)
            $0.lineBreakMode = .byTruncatingTail
        }
        [professorNameLabel, classTimeLabel].forEach { $0.font = .appFont(.pretendardRegular, size: 12) }
        metadataStackView.axis = .horizontal
        metadataStackView.spacing = 8
        metadataStackView.alignment = .center
        [yearLabel, gradeLabel, lectureClassLabel, classCodeLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }

    private func setUpLayouts() {
        [yearLabel, gradeLabel, lectureClassLabel, classCodeLabel].forEach { metadataStackView.addArrangedSubview($0) }
        [selectionView, classTitleLabel, professorNameLabel, classTimeLabel, metadataStackView, modifyClassButton].forEach { contentView.addSubview($0) }
    }

    private func setUpConstraints() {
        selectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(-8)
        }
        classTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(modifyClassButton.snp.leading).offset(-8)
            $0.height.equalTo(19)
        }
        professorNameLabel.snp.makeConstraints {
            $0.top.equalTo(classTitleLabel.snp.bottom)
            $0.leading.trailing.height.equalTo(classTitleLabel)
        }
        classTimeLabel.snp.makeConstraints {
            $0.top.equalTo(professorNameLabel.snp.bottom)
            $0.leading.trailing.height.equalTo(classTitleLabel)
        }
        metadataStackView.snp.makeConstraints {
            $0.top.equalTo(classTimeLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(19)
        }
        modifyClassButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
