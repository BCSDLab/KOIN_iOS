//
//  SelectDeptModalViewController.swift
//  koin
//
//  Created by 홍기정 on 8/23/26.
//

import UIKit

final class SelectDeptModalViewController: KoinModalViewController {
    
    // MARK: - Properties
    private let onCompleteButtonTapped: (String?)->Void
    
    // MARK: - Radio Button
    private let departmentRadioButtonGroup = RadioButtonGroup()
    
    // MARK: - State
    var selectedDepartment: String? {
        departmentRadioButtonGroup.selectedRadioButton?.accessibilityLabel
    }
    
    // MARK: - UI Components
    private let customView = UIView()
    
    private let titleLabel = UILabel()
    
    private let departmentScrollView = UIScrollView()
    private let departmentStackView = UIStackView()
    private var departmentRadioButtons: [RadioButton] = []
    
    private let cancelButton = UIButton()
    private let completeButton = UIButton()
    
    // MARK: - Initializer
    init(
        departments: [String],
        selectedDapartment: String? = nil,
        onCompleteButtonTapped: @escaping (String?)->Void
    ) {
        self.onCompleteButtonTapped = onCompleteButtonTapped
        
        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: customView),
            button: .none,
            layout: .init(
                width: 327,
                contentTopPadding: 0,
                contentHorizontalPadding: 0,
                contentBottomPadding: 0
            )
        ))
        
        setUpRadioButtons(
            departments: departments,
            selectedDapartment: selectedDapartment
        )
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
    }
}
    
extension SelectDeptModalViewController {
    private func setUpRadioButtons(
        departments: [String],
        selectedDapartment: String? = nil
    ) {
        for department in departments {
            let radioButton = RadioButton(title: department)
            
            departmentRadioButtons.append(radioButton)
            departmentRadioButtonGroup.addRadioButton(radioButton)
            
            if department == selectedDapartment {
                departmentRadioButtonGroup.selectRadioButton(radioButton)
            }
        }
    }
}

extension SelectDeptModalViewController {
    private func setAddTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonButtonTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func completeButtonTapped() {
        onCompleteButtonTapped(selectedDepartment)
        dismiss(animated: true)
    }
}

extension SelectDeptModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.text = "전공선택"
            $0.textColor = .appColor(.primary500)
            $0.font = .appFont(.pretendardSemiBold, size: 18)
        }
        
        departmentScrollView.do {
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            $0.verticalScrollIndicatorInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        
        departmentStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .fill
        }
        
        cancelButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "취소",
                    attributes: [
                        .font: UIFont.appFont(.pretendardMedium, size: 14),
                        .foregroundColor: UIColor.appColor(.neutral500)
                    ]),
                for: .normal
            )
        }
        completeButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "완료",
                    attributes: [
                        .font: UIFont.appFont(.pretendardMedium, size: 14),
                        .foregroundColor: UIColor.appColor(.neutral0)
                    ]),
                for: .normal
            )
            $0.backgroundColor = .appColor(.primary500)
            $0.layer.cornerRadius = 6
        }
    }
    
    private func setUpLayouts() {
        departmentRadioButtons.forEach {
            departmentStackView.addArrangedSubview($0)
        }
        
        [departmentStackView].forEach {
            departmentScrollView.addSubview($0)
        }
        
        [titleLabel,
         departmentScrollView,
         cancelButton,
         completeButton].forEach {
            customView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        
        departmentScrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(323)
        }
        
        departmentStackView.snp.makeConstraints {
            $0.edges.equalTo(departmentScrollView.contentLayoutGuide)
            $0.width.equalTo(departmentScrollView)
        }
        
        departmentRadioButtons.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(24)
            }
        }
        
        completeButton.snp.makeConstraints {
            $0.width.equalTo(49)
            $0.height.equalTo(30)
            $0.top.equalTo(departmentScrollView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(49)
            $0.height.equalTo(30)
            $0.trailing.equalTo(completeButton.snp.leading).offset(-8)
            $0.bottom.equalTo(completeButton)
        }
    }
}
