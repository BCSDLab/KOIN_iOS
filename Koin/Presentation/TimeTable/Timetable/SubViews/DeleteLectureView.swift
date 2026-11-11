//
//  DeleteLectureView.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine
import UIKit

final class DeleteLectureView: UIView, TimetableSheetSizing {
    // MARK: - Properties
    let deleteButtonPublisher = PassthroughSubject<LectureData, Never>()
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    let editButtonPublisher = PassthroughSubject<LectureData, Never>()
    private(set) var info: LectureData?

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    private let titleView = TimetableSheetTitleView(title: "수업 상세")
    private let buttonBar = TimetableSheetButtonBar(secondaryTitle: "강의 삭제")
    private let detailsStackView = UIStackView()
    private let classTitleLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let professorNameLabel = UILabel()
    private let classTimeLabel = UILabel()
    private let metadataStackView = UIStackView()
    private let gradeLabel = UILabel()
    private let lectureClassLabel = UILabel()
    private let classCodeLabel = UILabel()

    init() {
        super.init(frame: .zero)
        configureView()
        titleView.closePublisher.sink { [weak self] in self?.completeButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.primaryPublisher.sink { [weak self] in self?.completeButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.secondaryPublisher.sink { [weak self] in self?.deleteButtonTapped() }.store(in: &subscriptions)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func calculateSheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        min(systemLayoutSizeFitting(
            CGSize(width: context.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height, context.maximumHeight)
    }

    func configure(lecture: LectureData) {
        info = lecture
        classTitleLabel.text = lecture.name
        setText(lecture.professor, on: professorNameLabel)
        setText(lecture.classTime.timeLabelText(), on: classTimeLabel)
        let grades = lecture.grades.trimmingCharacters(in: .whitespacesAndNewlines)
        setText(grades.isEmpty ? nil : "\(grades)학점", on: gradeLabel)
        setText(lecture.lectureClass, on: lectureClassLabel)
        setText(lecture.code, on: classCodeLabel)
        let isCustom = lecture.lectureId == nil
        metadataStackView.isHidden = isCustom || [gradeLabel, lectureClassLabel, classCodeLabel].allSatisfy(\.isHidden)
        detailsStackView.snp.updateConstraints {
            $0.trailing.equalToSuperview().offset(isCustom ? -64 : -32)
            $0.height.greaterThanOrEqualTo(isCustom ? 66 : 76)
        }
        // 직접 추가 요청은 lecture_id=nil, 카탈로그 수업은 해당 lecture_id를 가진다.
        editButton.isHidden = lecture.lectureId != nil
    }

    private func setText(_ text: String?, on label: UILabel) {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        label.text = value
        label.isHidden = value.isEmpty
    }

    @objc private func deleteButtonTapped() {
        guard let info else { return }
        deleteButtonPublisher.send(info)
    }

    @objc private func editButtonTapped() {
        guard let info, info.lectureId == nil else { return }
        editButtonPublisher.send(info)
    }
}

extension DeleteLectureView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        detailsStackView.axis = .vertical
        detailsStackView.distribution = .equalSpacing
        classTitleLabel.font = .appFont(.pretendardSemiBold, size: 12)
        [classTitleLabel, professorNameLabel, classTimeLabel].forEach {
            $0.textColor = .appColor(.neutral800)
            $0.numberOfLines = 0
        }
        [professorNameLabel, classTimeLabel].forEach { $0.font = .appFont(.pretendardRegular, size: 12) }
        editButton.setImage(UIImage.appImage(asset: .profileSetting)?.withRenderingMode(.alwaysOriginal), for: .normal)
        editButton.accessibilityLabel = "일정 수정"
        editButton.isHidden = true
        metadataStackView.axis = .horizontal
        metadataStackView.spacing = 8
        metadataStackView.alignment = .center
        [gradeLabel, lectureClassLabel, classCodeLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
    }

    private func setUpLayouts() {
        [gradeLabel, lectureClassLabel, classCodeLabel].forEach { metadataStackView.addArrangedSubview($0) }
        [classTitleLabel, professorNameLabel, classTimeLabel, metadataStackView].forEach { detailsStackView.addArrangedSubview($0) }
        [titleView, detailsStackView, editButton, buttonBar].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        detailsStackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.greaterThanOrEqualTo(76)
        }
        [classTitleLabel, professorNameLabel, classTimeLabel, metadataStackView].forEach { label in
            label.snp.makeConstraints { $0.height.greaterThanOrEqualTo(19).priority(999) }
        }
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.centerY.equalTo(detailsStackView)
            $0.size.equalTo(24)
        }
        buttonBar.snp.makeConstraints {
            $0.top.equalTo(detailsStackView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
