//
//  PostLostItemFoundPlaceView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class PostLostItemFoundPlaceView: UIView {
    
    // MARK: - Properties
    private var type: LostItemType
    private lazy var textFieldPlaceHolder = "\(type.description) 장소를 입력해주세요."
    let shouldDismissDropDownPublisher = PassthroughSubject<Void, Never>()
    
    var isValid: Bool {
        locationWarningLabel.isHidden
    }
    
    // MARK: - UI Components
    private lazy var locationLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = (type == .lost ? "분실 장소" : "습득 장소")
    }
    private lazy var locationWarningLabel = UILabel().then {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.appImage(asset: .warningOrange)
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
        let spacingAttachment = NSTextAttachment()
        spacingAttachment.bounds = CGRect(x: 0, y: 0, width: 6, height: 1)
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(attachment: spacingAttachment))
        let text = "습득장소가 입력되지 않았습니다."
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.sub500)
        ]
        attributedString.append(NSAttributedString(string: text, attributes: textAttributes))
        $0.attributedText = attributedString
        $0.isHidden = true
    }
    private(set) lazy var locationTextField = UITextField().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    // MARK: - Initializer
    init(type: LostItemType, foundPlace: String?) {
        self.type = type
        super.init(frame: .zero)
        
        if let foundPlace {
            locationTextField.text = foundPlace
            locationTextField.textColor = .appColor(.neutral800)
        } else {
            locationTextField.text = textFieldPlaceHolder
            locationTextField.textColor = .appColor(.neutral500)
        }
        
        configureView()
        setAddTargets()
        setDelegate()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostLostItemFoundPlaceView {
    
    private func setDelegate() {
        locationTextField.delegate = self
    }
    
    private func setAddTargets() {
        locationTextField.addTarget(self, action: #selector(locationTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func locationTextFieldDidChange(_ textField: UITextField) {
        locationWarningLabel.isHidden = true
    }
}

extension PostLostItemFoundPlaceView: UITextFieldDelegate {
    
    // MARK: 장소 수정 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shouldDismissDropDownPublisher.send()
        
        // placeholder 비우기
        if textField.textColor == UIColor.appColor(.neutral500) {
            textField.text = ""
            textField.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    // MARK: 장소 수정 완료
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditing(true)
        
        if (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            textField.textColor = UIColor.appColor(.neutral500)
            textField.text = "\(type.description) 장소를 입력해주세요."
            locationWarningLabel.isHidden = (type == .lost)
        }
    }
    
    // MARK: 엔터키 눌러서 종료
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}


extension PostLostItemFoundPlaceView {
    
    private func setUpLayouts() {
        [locationLabel, locationWarningLabel, locationTextField].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        locationLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        locationWarningLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(22)
        }
        locationTextField.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(35)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
