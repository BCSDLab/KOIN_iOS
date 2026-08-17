//
//  SelectDeptModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/6/24.
//

import UIKit

final class SelectDeptModalViewController: KoinModalViewController {

    private enum Layout {
        static let buttonsPerRow: Int = 2
        static let gridSpacing: CGFloat = 4.8
        static let departmentButtonHeight: CGFloat = 32
        static let departmentButtonCornerRadius: CGFloat = 4
    }

    // MARK: - Properties
    private let onDepartmentSelected: (String?) -> Void
    private let departments = [
        "디자인ㆍ건축공학부",
        "고용서비스정책학과",
        "기계공학부",
        "메카트로닉스공학부",
        "산업경영학부",
        "전기ㆍ전자ㆍ통신공학부",
        "컴퓨터공학부",
        "에너지신소재화학공학부",
        "HRD학과",
        "교양학부",
        "안전공학과",
        "융합학과"
    ]
    private var selectedDepartment: String? = nil
    private var selectedButton: UIButton? = nil

    // MARK: - UI Components
    private let containerView = UIView()
    private let messageLabel = UILabel()
    private let gridStackView = UIStackView()
    private var departmentButtons: [UIButton] = []
    private let completeButton = UIButton()

    // MARK: - Initializer
    init(
        onDepartmentSelected: @escaping (String?) -> Void
    ) {
        self.onDepartmentSelected = onDepartmentSelected

        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: containerView),
            button: .none,
            layout: .init(
                width: 327,
                contentTopPadding: 18,
                contentHorizontalPadding: 12,
                contentBottomPadding: 18
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
        setUpDepartments()
        setAddTarget()
    }
}

extension SelectDeptModalViewController {
    private func setAddTarget() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func completeButtonTapped() {
        onDepartmentSelected(selectedDepartment)
        dismiss(animated: true)
    }
}

extension SelectDeptModalViewController {
    private func setUpDepartments() {
        var currentRow: UIStackView? = nil

        for (index, department) in departments.enumerated() {
            let button = createDepartmentButton(title: department)
            departmentButtons.append(button)

            if index % Layout.buttonsPerRow == 0 {
                currentRow = makeRowStackView()
                gridStackView.addArrangedSubview(currentRow!)
            }

            currentRow?.addArrangedSubview(button)
        }
    }

    private func makeRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.do {
            $0.axis = .horizontal
            $0.spacing = Layout.gridSpacing
            $0.distribution = .fillEqually
        }
        return stackView
    }

    private func createDepartmentButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.do {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 14)
            $0.layer.cornerRadius = Layout.departmentButtonCornerRadius
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.addTarget(self, action: #selector(departmentButtonTapped(_:)), for: .touchUpInside)
        }
        button.snp.makeConstraints {
            $0.height.equalTo(Layout.departmentButtonHeight)
        }
        apply(isSelected: false, to: button)
        return button
    }

    private func apply(isSelected: Bool, to button: UIButton) {
        button.backgroundColor = .appColor(isSelected ? .primary500 : .neutral0)
        button.setTitleColor(.appColor(isSelected ? .neutral0 : .neutral800), for: .normal)
    }

    // MARK: - Objc
    @objc private func departmentButtonTapped(_ sender: UIButton) {
        guard let department = sender.title(for: .normal) else { return }

        if selectedButton == sender {
            apply(isSelected: false, to: sender)
            selectedButton = nil
            selectedDepartment = nil
        } else {
            departmentButtons.forEach { apply(isSelected: false, to: $0) }
            apply(isSelected: true, to: sender)
            selectedButton = sender
            selectedDepartment = department
        }
    }
}

extension SelectDeptModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        messageLabel.do {
            $0.text = "전공선택"
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.textColor = .appColor(.primary500)
        }

        gridStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.gridSpacing
            $0.distribution = .fill
        }
        
        completeButton.do {
            $0.backgroundColor = UIColor.appColor(.primary500)
            $0.setTitle("완료", for: .normal)
            $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
            $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
    }

    private func setUpLayouts() {
        [messageLabel, gridStackView, completeButton].forEach {
            containerView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(29)
        }
        gridStackView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        completeButton.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(30)
            $0.top.equalTo(gridStackView.snp.bottom).offset(6)
            $0.trailing.bottom.equalToSuperview()
        }
    }
}
