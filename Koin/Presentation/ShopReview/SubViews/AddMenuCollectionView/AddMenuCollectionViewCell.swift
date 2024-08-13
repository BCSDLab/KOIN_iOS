//
//  AddMenuCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit

final class AddMenuCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    let textPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - UI Components
    
    private let addMenuTextField = UITextField().then {
        $0.placeholder = "메뉴를 직접 입력해주세요."
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    private let cancelButton =  UIButton().then {
        $0.setImage(UIImage.appImage(asset: .trashcan), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addMenuTextField.delegate = self
        
        addMenuTextField.textPublisher()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.textPublisher.send(text)
            }.store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    @objc private func cancelButtonTapped() {
        cancelButtonPublisher.send(())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textPublisher.send(textField.text ?? "")
    }
    func configure(text: String) {
        addMenuTextField.text = text
    }
}

extension AddMenuCollectionViewCell {
    private func setUpLayouts() {
        [addMenuTextField, cancelButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        addMenuTextField.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(cancelButton.snp.leading).offset(-10)
        }
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
