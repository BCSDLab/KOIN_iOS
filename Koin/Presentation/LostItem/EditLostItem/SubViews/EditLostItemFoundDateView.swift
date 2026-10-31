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
    
    /// 서버 값이 비었거나 파싱되지 않으면 날짜를 고르기 전까지 무효
    var isValid: Bool {
        foundDateValue != nil
    }
    /// 서버 found_date(yyyy-MM-dd). 사용자가 바꾸기 전에는 서버 값 그대로
    var foundDate: String {
        foundDateValue?.string(with: .yearMonthDayHyphen) ?? originalFoundDate
    }
    private let originalFoundDate: String
    private var foundDateValue: Date?
    
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
    private let dropdownView: KoinPickerDropDownView

    // MARK: - Initializer
    /// now: 화면 진입 시 고정한 시각(습득일 범위 기준)
    init(type: LostItemType, foundDate: String, now: Date) {
        self.type = type
        self.originalFoundDate = foundDate
        // 서버 값은 보정하지 않고 그대로 표시
        self.foundDateValue = Date(string: foundDate, format: .yearMonthDayHyphen)
        self.dropdownView = KoinPickerDropDownView(configuration: .lostItemDate(now: now), buttonColor: .appColor(.primary600)).then {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 12
        }
        
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
        updateDateButton()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        dropdownView.datePublisher.sink { [weak self] date in
            self?.updateFoundDate(date)
        }.store(in: &subscriptions)
    }
    
    private func setAddTargets() {
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    /// 드롭다운형: 값 있으면 setDate, 없으면 보정된 picker.date 즉시 반영(setDate는 이벤트 없음)
    @objc private func dateButtonTapped(button: UIButton) {
        if let foundDateValue {
            dropdownView.setDate(foundDateValue)
        } else {
            dropdownView.setDate(Date())
            updateFoundDate(dropdownView.date)
        }
        presentDropdown(
            anchor: dateButton,
            content: dropdownView,
            configuration: .init(direction: .down(spacing: 4), shadow: .shadow2)
        )
    }
    
    /// 저장 시점 검증: 무효면 경고 라벨 표시
    func validateInput() -> Bool {
        dateWarningLabel.isHidden = isValid
        return isValid
    }
    
    private func updateFoundDate(_ date: Date) {
        foundDateValue = date
        updateDateButton()
        dateWarningLabel.isHidden = true
    }
    
    private func updateDateButton() {
        if let foundDateValue {
            dateButton.setTitle(foundDateValue.string(with: .yearMonthDay), for: .normal)
            dateButton.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        } else {
            dateButton.setTitle("\(type.description) 일자를 입력해주세요.", for: .normal)
            dateButton.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        }
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
