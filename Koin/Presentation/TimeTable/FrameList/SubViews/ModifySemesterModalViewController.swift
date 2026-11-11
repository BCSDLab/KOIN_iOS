//
//  ModifySemesterModalViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class ModifySemesterModalViewController: KoinModalViewController {
    private enum Step {
        case year
        case semester
    }

    // MARK: - Properties
    private let onApplyButtonTapped: ([String], [String]) -> Void
    private let yearRadioButtonGroup = RadioButtonGroup()
    /// 서버 학기 목록(/semesters). 오래된 학기부터 정렬되어 있다.
    private let semesters: [String]
    private let years: [String]

    // MARK: - State
    private var frameList: [FrameData] = []
    private var step: Step = .year
    private var selectedYear: String
    private var selectedSemesters: Set<String> = []

    private var semesterCodes: [String] {
        semesters.filter { $0.hasPrefix(selectedYear) }
    }

    // MARK: - UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let optionsScrollView = UIScrollView()
    private let optionsStackView = UIStackView()
    private let yearStackView = UIStackView()
    private let semesterStackView = UIStackView()
    private var yearButtons: [RadioButton] = []
    private var semesterButtons: [RadioButton] = []
    private let buttonStackView = UIStackView()
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)

    // MARK: - Initializer
    init(semesters: [String], onApplyButtonTapped: @escaping ([String], [String]) -> Void) {
        self.onApplyButtonTapped = onApplyButtonTapped
        self.semesters = semesters
        years = Array(Set(semesters.map { String($0.prefix(4)) })).sorted(by: >)
        selectedYear = years.first ?? ""
        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: containerView),
            button: .none,
            layout: .init(
                width: 327,
                contentTopPadding: 20,
                contentHorizontalPadding: 24,
                contentBottomPadding: 20
            )
        ))
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRadioButtons()
        configureView()
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
        resetSemesterSelection()
        updateStep()
    }

    // MARK: - Public
    func configure(frameList: [FrameData]) {
        self.frameList = frameList
        resetSemesterSelection()
    }
}

extension ModifySemesterModalViewController {
    private func setUpRadioButtons() {
        yearButtons = years.enumerated().map { index, year in
            let button = RadioButton(title: year)
            button.tag = index
            yearRadioButtonGroup.addRadioButton(button)
            if year == selectedYear {
                yearRadioButtonGroup.selectRadioButton(button)
            }
            return button
        }
        yearRadioButtonGroup.onSelectionChanged = { [weak self] button in
            guard let self, let button, self.years.indices.contains(button.tag),
                  self.selectedYear != self.years[button.tag] else { return }
            self.selectedYear = self.years[button.tag]
            self.resetSemesterSelection()
        }
    }

    /// 연도마다 학기 수가 달라서 학기 버튼을 다시 만든다.
    private func rebuildSemesterButtons() {
        semesterButtons.forEach { $0.removeFromSuperview() }
        semesterButtons = semesterCodes.enumerated().map { index, code in
            let button = RadioButton(title: Self.title(of: code))
            button.tag = index
            // Core RadioButton의 단일 선택 동작을 이 화면의 다중 선택으로 연결한다.
            // 기본 touchUpInside target만 교체하고 외형과 접근성 갱신은 그대로 재사용한다.
            button.removeTarget(button, action: nil, for: .touchUpInside)
            button.addTarget(self, action: #selector(semesterButtonPressed(_:)), for: .touchUpInside)
            semesterStackView.addArrangedSubview(button)
            button.snp.makeConstraints { $0.height.equalTo(24) }
            return button
        }
    }

    static func title(of code: String) -> String {
        switch code.dropFirst(4) {
        case "1": return "1학기"
        case "-여름": return "여름학기"
        case "2": return "2학기"
        case "-겨울": return "겨울학기"
        default: return code
        }
    }

    private func resetSemesterSelection() {
        rebuildSemesterButtons()
        selectedSemesters = Set(semesterCodes).intersection(frameList.map(\.semester))
        // 등록된 학기가 없는 연도는 가장 최근 학기를 미리 고른다.
        if selectedSemesters.isEmpty, let latest = semesterCodes.last {
            selectedSemesters.insert(latest)
        }
        updateSemesterButtons()
    }

    private func updateSemesterButtons() {
        for (button, code) in zip(semesterButtons, semesterCodes) {
            button.isSelected = selectedSemesters.contains(code)
        }
    }

    private func updateStep() {
        let isYear = step == .year
        titleLabel.text = isYear ? "연도 선택" : "학기 추가(중복 가능)"
        // 숨김 높이 0과 RadioButton의 최소 높이 제약이 충돌하지 않도록 목록을 교체한다.
        optionsStackView.arrangedSubviews.forEach {
            optionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        optionsStackView.addArrangedSubview(isYear ? yearStackView : semesterStackView)
        TimetableButtonTitle.set(isYear ? "취소하기" : "이전", on: leftButton, font: .pretendardMedium, size: 15, color: .neutral600)
        TimetableButtonTitle.set(isYear ? "다음" : "적용하기", on: rightButton, font: .pretendardMedium, size: 15, color: .neutral0)
        // 학기 버튼 높이 24, 간격 8. 학기 수만큼만 높이를 잡는다.
        let semesterCount = CGFloat(semesterButtons.count)
        optionsScrollView.snp.updateConstraints {
            $0.height.equalTo(isYear ? 140 : max(0, semesterCount * 24 + (semesterCount - 1) * 8))
        }
        optionsScrollView.setContentOffset(.zero, animated: false)
    }

    @objc private func semesterButtonPressed(_ sender: RadioButton) {
        let code = semesterCodes[sender.tag]
        // 모두 해제하고 적용하면 해당 연도의 학기를 모두 삭제한다.
        if selectedSemesters.contains(code) {
            selectedSemesters.remove(code)
        } else {
            selectedSemesters.insert(code)
        }
        updateSemesterButtons()
    }

    @objc private func leftButtonPressed() {
        if step == .year {
            dismiss(animated: true)
        } else {
            step = .year
            updateStep()
        }
    }

    @objc private func rightButtonPressed() {
        if step == .year {
            step = .semester
            updateStep()
            return
        }
        let existingSemesters = Set(frameList.map(\.semester))
        let added = semesterCodes.filter { selectedSemesters.contains($0) && !existingSemesters.contains($0) }
        let removed = semesterCodes.filter { !selectedSemesters.contains($0) && existingSemesters.contains($0) }
        let onApply = onApplyButtonTapped
        dismiss(animated: true) {
            onApply(added, removed)
        }
    }
}

extension ModifySemesterModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        titleLabel.font = .appFont(.pretendardSemiBold, size: 18)
        titleLabel.textColor = .appColor(.new500)
        titleLabel.numberOfLines = 0
        [optionsStackView, yearStackView, semesterStackView].forEach {
            $0.axis = .vertical
            $0.alignment = .fill
        }
        yearStackView.spacing = 8
        semesterStackView.spacing = 8
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        [leftButton, rightButton].forEach {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
            $0.configuration = configuration
            $0.layer.cornerRadius = 4
        }
        leftButton.setTitleColor(.appColor(.neutral600), for: .normal)
        leftButton.layer.borderColor = UIColor.appColor(.gray).cgColor
        leftButton.layer.borderWidth = 1
        rightButton.setTitleColor(.appColor(.neutral0), for: .normal)
        rightButton.backgroundColor = .appColor(.new500)
    }

    private func setUpLayouts() {
        yearButtons.forEach { yearStackView.addArrangedSubview($0) }
        optionsStackView.addArrangedSubview(yearStackView)
        optionsScrollView.addSubview(optionsStackView)
        [leftButton, rightButton].forEach { buttonStackView.addArrangedSubview($0) }
        [titleLabel, optionsScrollView, buttonStackView].forEach { containerView.addSubview($0) }
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(29)
        }
        optionsScrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
        optionsStackView.snp.makeConstraints {
            $0.edges.equalTo(optionsScrollView.contentLayoutGuide)
            $0.width.equalTo(optionsScrollView.frameLayoutGuide)
        }
        yearButtons.forEach { button in
            button.snp.makeConstraints { $0.height.equalTo(24) }
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(optionsScrollView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
}
