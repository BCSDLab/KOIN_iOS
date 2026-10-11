//
//  EditLostItemFoundDateView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class EditLostItemFoundDateView: UIView {
    
    // MARK: - Properties
    private var type: LostItemType
    private var subscriptions: Set<AnyCancellable> = []
    
    var isValid: Bool {
        dateWarningLabel.isHidden
    }
    private(set) var foundDate: String
    
    // MARK: - UI Components
    private lazy var dateLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "\(type.description) 일자"
    }
    private let essentialLabel = UILabel().then {
        $0.attributedText = NSAttributedString(
            string: " *",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 11),
                .foregroundColor : UIColor(hexCode: "C82A2A")
            ]
        )
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
    }

    // MARK: - Dropdown
    var dropdownTrigger: UIView { dateButton }
    var dropdownContentView: UIView & KoinDropdownContentView { dropdownView }
    private var dropdown: KoinDropdown?
    
    // MARK: - Initializer
    init(type: LostItemType, foundDate: String) {
        self.type = type
        self.foundDate = foundDate
        
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
        endEditing(true)
        dropdown?.toggle()
    }

    /// ScrollView 를 아는 호출부가 Host 를 넘겨준다.
    func prepareDropdown(host: KoinDropdownHost) {
        guard dropdown == nil else { return }
        dropdown = host.makeDropdown(
            anchor: dateButton,
            contentView: dropdownView,
            configuration: .init(topPadding: 4, shadow: .shadow2)
        )
    }
    
    private func dropdownValueChanged() {
        // shouldScrollTo(dropdownView)
        
        let displayDate = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: dropdownView.dateValue)
        }()
        dateButton.setTitle(displayDate, for: .normal)
        dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        dateWarningLabel.isHidden = true
        
        let formattedDate = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: dropdownView.dateValue)
        }()
        self.foundDate = formattedDate
    }
}

extension EditLostItemFoundDateView {
    
    private func setUpLayouts() {
        [dateLabel, dateWarningLabel, dateButton, chevronImage, essentialLabel].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        essentialLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(18)
            $0.leading.equalTo(dateLabel.snp.trailing)
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
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
