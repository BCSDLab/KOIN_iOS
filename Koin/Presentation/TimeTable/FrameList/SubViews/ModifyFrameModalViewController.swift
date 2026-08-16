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
    
    // MARK: - UI Components
    let containerView = UIView()
    
    let messageLabel = UILabel()
    let deleteButton = UIButton()
    let textField = UITextField()
    
    let checkButtonWrapperView = UIView()
    let checkButton = UIButton()
    let buttonTextLabel = UILabel()
    
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
            button: .init(
                leftButtonTitle: "취소",
                rightButtonTitle: "저장",
                rightButtonAction: {} //rightButtonAction
            ),
            layout: .init(
                width: 327,
                contentTopPadding: 12,
                contentHorizontalPadding: 24,
                paddingBetweenContentAndButton: 10,
                buttonHorizontalPadding: 24,
                buttonBottomPadding: 16
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
    }
    
    // MARK: - Public
    func configure(frame: FrameDto) {
        self.frame = frame
        self.textField.attributedPlaceholder = NSAttributedString(
            string: frame.timetableName,
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral500)
            ])
        self.frame = frame
        self.checkButton.setImage(UIImage.appImage(asset: frame.isMain ? .checkFill : .checkEmpty), for: .normal)
    }
    
    // MARK: - Override
    override func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onSaveButtonTapped(frame)
        }
    }
}

extension ModifyFrameModalViewController {
    private func setUpDelegate() {
        textField.delegate = self
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 내리기
        return true
    }
}

extension ModifyFrameModalViewController {
    private func setUpAddTargets() {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        frame.timetableName = text
    }
    
    @objc private func checkButtonTapped() {
        frame.isMain.toggle()
        checkButton.setImage(UIImage.appImage(asset: frame.isMain ? .checkFill : .checkEmpty), for: .normal)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onDeleteButtonTapped(frame)
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
        }
        
        deleteButton.do {
            $0.backgroundColor = UIColor.appColor(.danger700)
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
            $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
        
        textField.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 4
            $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 22))
            $0.leftViewMode = .always
            $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 22))
            $0.rightViewMode = .always
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        
        buttonTextLabel.do {
            $0.text = "기본 시간표로 설정하기"
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        }
    }
    private func setUpLayouts() {
        [checkButton, buttonTextLabel].forEach {
            checkButtonWrapperView.addSubview($0)
        }
        [deleteButton, messageLabel, textField, checkButtonWrapperView].forEach {
            containerView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        deleteButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(14)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
            make.height.equalTo(46)
        }
        checkButtonWrapperView.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(24)
        }
        buttonTextLabel.snp.makeConstraints {
            $0.centerY.equalTo(checkButton)
            $0.leading.equalTo(checkButton.snp.trailing).offset(5)
            $0.trailing.equalToSuperview()
        }
    }
}
