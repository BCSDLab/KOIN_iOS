//
//  DeleteFrameModalViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine
import UIKit

final class DeleteFrameModalViewController: UIViewController {
    
    
    let deleteButtonPublisher = PassthroughSubject<FrameDTO, Never>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    let saveButtonPublisher = PassthroughSubject<FrameDTO, Never>()
    var containerWidth: CGFloat
    var containerHeight: CGFloat
    var frame: FrameDTO = FrameDTO(id: 0, timetableName: "", isMain: false)
    
    private let messageLabel = UILabel().then {
        $0.text = "시간표 설정"
        $0.font = UIFont.appFont(.pretendardRegular, size: 17)
    }
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.danger700)
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let textField = UITextField().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let checkButton = UIButton().then { _ in
    }
    private let buttonTextLabel = UILabel().then {
        $0.text = "기본 시간표로 설정하기"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }

    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let saveButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    init(width: CGFloat, height: CGFloat) {
        self.containerWidth = width
        self.containerHeight = height
        super.init(nibName: nil, bundle: nil)
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    func configure(frame: FrameDTO) {
        self.frame = frame
        self.textField.text = frame.timetableName
        self.frame = frame
        self.checkButton.setImage(UIImage.appImage(asset: frame.isMain ? .checkFill : .checkEmpty), for: .normal)
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
        deleteButtonPublisher.send(frame)
        dismiss(animated: true, completion: nil)
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        saveButtonPublisher.send(frame)
        dismiss(animated: true, completion: nil)
    }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // 키보드 내리기
            return true
        }
   
}

extension DeleteFrameModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [deleteButton, messageLabel, textField, checkButton, buttonTextLabel, cancelButton, saveButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(containerWidth)
            make.height.equalTo(containerHeight)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(13)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(deleteButton.snp.bottom)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(14)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
            make.height.equalTo(46)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.equalTo(textField.snp.leading).offset(61)
            make.width.height.equalTo(24)
        }
        buttonTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButton.snp.centerY)
            make.leading.equalTo(checkButton.snp.trailing).offset(5)
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(135.5)
            make.height.equalTo(48)
            make.trailing.equalTo(containerView.snp.centerX).offset(-4)
            make.bottom.equalTo(containerView.snp.bottom).offset(-16)
        }
        saveButton.snp.makeConstraints { make in
            make.width.height.bottom.equalTo(cancelButton)
            make.leading.equalTo(containerView.snp.centerX).offset(4)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
