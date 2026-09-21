//
//  ModifySemesterModalViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class ModifySemesterModalViewController: KoinModalViewController {

    private enum Layout {
        static let yearButtonWidth: CGFloat = 90
        static let yearButtonHeight: CGFloat = 24
        static let messageLabelTopOffset: CGFloat = 12
        static let messageLabelHeight: CGFloat = 26
        static let semesterButtonWidth: CGFloat = 125
        static let semesterButtonHeight: CGFloat = 40
        static let semesterButtonCornerRadius: CGFloat = 4
        static let paddingBetweenMessageAndSemester: CGFloat = 10
        static let paddingBetweenSemesterRows: CGFloat = 10
    }

    private enum SemesterState: Int {
        case unselected = 0
        case added = 1
        case existing = 2
        case removed = 3
    }

    // MARK: - Properties
    private let onApplyButtonTapped: ([String], [String]) -> Void

    // MARK: - State
    private var frameList: [FrameData] = []
    private var selectedYear: String = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(currentYear)"
    }()

    private var semesterMapping: [(button: UIButton, semester: String)] {
        [
            (firstSemesterButton, "\(selectedYear)1"),
            (summerSemesterButton, "\(selectedYear)-여름"),
            (secondSemesterButton, "\(selectedYear)2"),
            (winterSemesterButton, "\(selectedYear)-겨울")
        ]
    }

    // MARK: - UI Components
    private let containerView = UIView()
    private let selectYearButton = UIButton()
    private let messageLabel = UILabel()
    private let firstSemesterButton = UIButton()
    private let summerSemesterButton = UIButton()
    private let secondSemesterButton = UIButton()
    private let winterSemesterButton = UIButton()

    // MARK: - Initializer
    init(onApplyButtonTapped: @escaping ([String], [String]) -> Void) {
        self.onApplyButtonTapped = onApplyButtonTapped

        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: containerView),
            button: .buttons(
                leftButtonTitle: "취소",
                rightButtonTitle: "적용하기",
                rightButtonAction: {}
            ),
            layout: .init(
                width: 327,
                contentTopPadding: 12,
                contentHorizontalPadding: 24,
                paddingBetweenContentAndButton: 10,
                buttonHorizontalPadding: 24
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setUpAddTargets()
        updateSemesterButtons()
    }

    // MARK: - Public
    func configure(frameList: [FrameData]) {
        self.frameList = frameList
        updateSemesterButtons()
    }

    // MARK: - Override
    override func rightButtonTapped() {
        var addedSemesters: [String] = []
        var removedSemesters: [String] = []

        for (button, semester) in semesterMapping {
            switch SemesterState(rawValue: button.tag) {
            case .added:
                addedSemesters.append(semester)
            case .removed:
                removedSemesters.append(semester)
            default:
                break
            }
        }

        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onApplyButtonTapped(addedSemesters, removedSemesters)
        }
    }
}

extension ModifySemesterModalViewController {
    private func setUpAddTargets() {
        selectYearButton.addTarget(self, action: #selector(selectYearButtonTapped), for: .touchUpInside)
        [firstSemesterButton, summerSemesterButton, secondSemesterButton, winterSemesterButton].forEach {
            $0.addTarget(self, action: #selector(semesterButtonTapped(_:)), for: .touchUpInside)
        }
    }

    private func updateSemesterButtons() {
        for (button, semester) in semesterMapping {
            let isExisting = frameList.contains { $0.semester == semester }
            apply(state: isExisting ? .existing : .unselected, to: button)
        }
    }

    private func apply(state: SemesterState, to button: UIButton) {
        button.tag = state.rawValue

        switch state {
        case .unselected:
            button.backgroundColor = .appColor(.neutral0)
            button.setTitleColor(.appColor(.neutral800), for: .normal)
        case .added, .existing:
            button.backgroundColor = .appColor(.success700)
            button.setTitleColor(.appColor(.neutral0), for: .normal)
        case .removed:
            button.backgroundColor = .appColor(.danger700)
            button.setTitleColor(.appColor(.neutral0), for: .normal)
        }
    }

    // MARK: - Objc
    @objc private func semesterButtonTapped(_ sender: UIButton) {
        switch SemesterState(rawValue: sender.tag) {
        case .unselected: // 초기 상태(흰색)
            apply(state: .added, to: sender)
        case .added: // 새로 선택된 학기(초록색)
            apply(state: .unselected, to: sender)
        case .existing: // 이미 존재하는 학기(초록색)
            apply(state: .removed, to: sender)
        case .removed: // 삭제 예정(빨간색)
            apply(state: .existing, to: sender)
        case .none:
            break
        }
    }

    @objc private func selectYearButtonTapped() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = (2019...currentYear).reversed().map { "\($0)" } // 2019년부터 현재 연도까지

        let alert = UIAlertController(title: "연도 선택", message: nil, preferredStyle: .actionSheet)

        for year in years {
            let action = UIAlertAction(title: year, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedYear = year
                self.selectYearButton.setTitle(year, for: .normal)
                self.updateSemesterButtons() // 선택된 연도에 따라 버튼 상태 업데이트
            }
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

extension ModifySemesterModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        selectYearButton.do {
            $0.backgroundColor = .appColor(.neutral300)
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 12)
            $0.setTitle(selectedYear, for: .normal)
            $0.setTitleColor(.appColor(.neutral800), for: .normal)
        }

        messageLabel.do {
            $0.text = "학기 편집"
            $0.font = .appFont(.pretendardBold, size: 18)
        }

        firstSemesterButton.setTitle("1학기", for: .normal)
        summerSemesterButton.setTitle("여름학기", for: .normal)
        secondSemesterButton.setTitle("2학기", for: .normal)
        winterSemesterButton.setTitle("겨울학기", for: .normal)

        [firstSemesterButton, summerSemesterButton, secondSemesterButton, winterSemesterButton].forEach {
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 16)
            $0.setTitleColor(.appColor(.neutral800), for: .normal)
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.cornerRadius = Layout.semesterButtonCornerRadius
            $0.layer.masksToBounds = true
        }
    }

    private func setUpLayouts() {
        [selectYearButton, messageLabel, firstSemesterButton, summerSemesterButton, secondSemesterButton, winterSemesterButton].forEach {
            containerView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        selectYearButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(Layout.yearButtonWidth)
            $0.height.equalTo(Layout.yearButtonHeight)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.messageLabelTopOffset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Layout.messageLabelHeight)
        }
        firstSemesterButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(Layout.paddingBetweenMessageAndSemester)
            $0.leading.equalToSuperview()
            $0.width.equalTo(Layout.semesterButtonWidth)
            $0.height.equalTo(Layout.semesterButtonHeight)
        }
        summerSemesterButton.snp.makeConstraints {
            $0.top.equalTo(firstSemesterButton)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(Layout.semesterButtonWidth)
            $0.height.equalTo(Layout.semesterButtonHeight)
        }
        secondSemesterButton.snp.makeConstraints {
            $0.top.equalTo(firstSemesterButton.snp.bottom).offset(Layout.paddingBetweenSemesterRows)
            $0.leading.equalTo(firstSemesterButton)
            $0.width.equalTo(Layout.semesterButtonWidth)
            $0.height.equalTo(Layout.semesterButtonHeight)
            $0.bottom.equalToSuperview()
        }
        winterSemesterButton.snp.makeConstraints {
            $0.top.equalTo(secondSemesterButton)
            $0.trailing.equalTo(summerSemesterButton)
            $0.width.equalTo(Layout.semesterButtonWidth)
            $0.height.equalTo(Layout.semesterButtonHeight)
        }
    }
}
