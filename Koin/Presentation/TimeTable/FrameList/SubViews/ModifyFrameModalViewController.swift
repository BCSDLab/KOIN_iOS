//
//  ModifyFrameModalViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

final class ModifyFrameModalViewController: KoinModalViewController {
    
    // MARK: - Properties
    private let onDeleteButtonTapped: (FrameDto) -> Void
    private let onSaveButtonTapped: (FrameDto) -> Void
    private var frame: FrameDto = FrameDto(id: 0, timetableName: "", isMain: false)

    private var trimmedName: String {
        (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool { !trimmedName.isEmpty }
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let messageLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let deleteButton = UIButton(type: .system)
    private let saveButton = StatefulButton(
        title: "저장",
        font: .appFont(.pretendardMedium, size: 15),
        enabledColor: .appColor(.new500),
        cornerRadius: 4
    )
    private let textField = UITextField()
    
    private let checkButtonWrapperView = UIControl()
    private let checkButton = UIImageView()
    private let buttonTextLabel = UILabel()
    
    // MARK: - Initializer
    init(
        onDeleteButtonTapped: @escaping (FrameDto) -> Void,
        onSaveButtonTapped: @escaping (FrameDto) -> Void
    ) {
        self.onDeleteButtonTapped = onDeleteButtonTapped
        self.onSaveButtonTapped = onSaveButtonTapped
        
        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: containerView),
            button: .none,
            layout: .init(
                width: 340,
                contentTopPadding: 26,
                contentHorizontalPadding: 30.5,
                contentBottomPadding: 26
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
        setUpDelegate()
        setUpAddTargets()
        saveButton.updateState(isEnabled: isValid)
    }
    
    // MARK: - Public
    func configure(frame: FrameDto) {
        self.frame = frame
        textField.text = frame.timetableName
        checkButtonWrapperView.isSelected = frame.isMain
        updateCheckButton()
        saveButton.updateState(isEnabled: isValid)
    }
}

extension ModifyFrameModalViewController {
    private func setUpDelegate() {
        textField.delegate = self
    }
}

extension ModifyFrameModalViewController {
    private func setUpAddTargets() {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        checkButtonWrapperView.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        saveButton.updateState(isEnabled: isValid)
    }
    
    @objc private func checkButtonTapped() {
        checkButtonWrapperView.isSelected.toggle()
        updateCheckButton()
    }

    private func updateCheckButton() {
        let isSelected = checkButtonWrapperView.isSelected
        checkButton.image = UIImage.appImage(asset: isSelected ? .checkFill : .checkEmpty)?
            .withRenderingMode(isSelected ? .alwaysTemplate : .alwaysOriginal)
        checkButtonWrapperView.accessibilityTraits = checkButtonWrapperView.isSelected ? [.button, .selected] : .button
    }

    @objc private func saveButtonTapped() {
        guard isValid else { return }
        var updatedFrame = frame
        updatedFrame.timetableName = trimmedName
        updatedFrame.isMain = checkButtonWrapperView.isSelected
        let onSave = onSaveButtonTapped
        dismiss(animated: true) {
            onSave(updatedFrame)
        }
    }
    
    @objc private func deleteButtonTapped() {
        let onDelete = onDeleteButtonTapped
        let frame = frame
        dismiss(animated: true) {
            onDelete(frame)
        }
    }
}

extension ModifyFrameModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        messageLabel.do {
            $0.text = "시간표 설정"
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 16)
            $0.textColor = .appColor(.neutral800)
            $0.textAlignment = .center
        }
        
        deleteButton.do {
            $0.setAttributedTitle(NSAttributedString(string: "삭제", attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral600)
            ]), for: .normal)
            $0.setTitleColor(.appColor(.neutral600), for: .normal)
            $0.titleLabel?.font = .appFont(.pretendardMedium, size: 15)
            $0.layer.borderColor = UIColor.appColor(.gray).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 4
        }

        saveButton.setAttributedTitle(NSAttributedString(string: "저장", attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 15)
        ]), for: .normal)
        [deleteButton, saveButton].forEach { $0.titleLabel?.numberOfLines = 1 }
        checkButton.tintColor = .appColor(.new500)
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        
        textField.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 20
            $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 22))
            $0.leftViewMode = .always
            $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 22))
            $0.rightViewMode = .always
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.accessibilityLabel = "시간표 이름"
        }
        
        buttonTextLabel.do {
            $0.text = "기본 시간표로 설정하기"
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = .appColor(.neutral800)
        }
        checkButtonWrapperView.isAccessibilityElement = true
        checkButtonWrapperView.accessibilityLabel = "기본 시간표로 설정하기"
    }
    private func setUpLayouts() {
        [checkButton, buttonTextLabel].forEach {
            checkButtonWrapperView.addSubview($0)
        }
        [deleteButton, saveButton].forEach { buttonStackView.addArrangedSubview($0) }
        [messageLabel, textField, checkButtonWrapperView, buttonStackView].forEach {
            containerView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
            make.height.equalTo(46)
        }
        checkButtonWrapperView.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom).offset(10)
        }
        
        checkButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        buttonTextLabel.snp.makeConstraints {
            $0.centerY.equalTo(checkButton)
            $0.leading.equalTo(checkButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(checkButtonWrapperView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
}
