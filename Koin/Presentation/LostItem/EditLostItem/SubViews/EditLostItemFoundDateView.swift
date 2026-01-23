//
//  EditLostItemFoundDateView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class EditLostItemFoundDateView: ExtendedTouchAreaView {
    
    // MARK: - Properties
    private var type: LostItemType
    private var subscriptions: Set<AnyCancellable> = []
    
    var isValid: Bool {
        dateWarningLabel.isHidden
    }
    
    // MARK: - UI Components
    private lazy var dateLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "\(type.description) 일자"
    }
    private lazy var dateWarningLabel = UILabel().then {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.appImage(asset: .warningOrange)
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
        let spacingAttachment = NSTextAttachment()
        spacingAttachment.bounds = CGRect(x: 0, y: 0, width: 6, height: 1)
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(attachment: spacingAttachment))
        let text = "\(type.description)일자가 입력되지 않았습니다."
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.sub500)
        ]
        attributedString.append(NSAttributedString(string: text, attributes: textAttributes))
        $0.attributedText = attributedString
        $0.isHidden = true
    }
    private let dateButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.contentHorizontalAlignment = .left
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    private let chevronImage = UIImageView().then {
        $0.image = UIImage.appImage(asset: .chevronDown)
        $0.isUserInteractionEnabled = false
    }
    private lazy var dropdownView = DatePickerDropdownView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.08, x: 0, y: 4, blur: 10, spread: 0)
        $0.isHidden = true
        $0.transform = CGAffineTransform(translationX: 0, y: -20)
        $0.alpha = 0
    }
    
    // MARK: - Initializer
    init(type: LostItemType, foundDate: String) {
        self.type = type
        
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
        
        let dateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
            formatter.dateFormat = "yyyy년 M월 d일" // 입력 형식
            return formatter
        }()
        if let dateValue = dateFormatter.date(from: foundDate) {
            dropdownView.dateValue = dateValue
        }
        
        let formattedDate: String = dateFormatter.string(from: dropdownView.dateValue)
        dateButton.setTitle(formattedDate, for: .normal)
        dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        dropdownView.valueChangedPublisher.sink { [weak self] in
            self?.dropdownValueChanged()
        }.store(in: &subscriptions)
    }
    
    private func setAddTargets() {
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dateButtonTapped(button: UIButton) {
        if dropdownView.isHidden {
            presentDropdown()
            endEditing(true)
        } else {
            dismissDropdown()
        }
    }
    
    private func presentDropdown() {
        // 열려있는 키보드 닫기
        self.endEditing(true)
        
        dropdownView.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            dropdownView.alpha = 1
            dropdownView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @objc func dismissDropdown() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            dropdownView.alpha = 0
            dropdownView.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1 ) { [weak self] in
            self?.dropdownView.isHidden = true
        }
    }
    
    private func dropdownValueChanged() {
        // shouldScrollTo(dropdownView)
        
        let formattedDate = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: dropdownView.dateValue)
        }()
        dateButton.setTitle(formattedDate, for: .normal)
        dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        dateWarningLabel.isHidden = true
    }
}

extension EditLostItemFoundDateView {
    
    private func setUpLayouts() {
        [dateLabel, dateWarningLabel, dateButton, chevronImage, dropdownView].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        dateWarningLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(22)
        }
        dateButton.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.height.equalTo(40)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        chevronImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalTo(dateButton)
            $0.trailing.equalTo(dateButton.snp.trailing).offset(-16)
        }
        dropdownView.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(dateButton)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
