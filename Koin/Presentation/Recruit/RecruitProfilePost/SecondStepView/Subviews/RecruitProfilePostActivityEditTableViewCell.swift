//
//  RecruitProfilePostActivityEditTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostActivityEditTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    let activityChangedPublisher = PassthroughSubject<RecruitProfileActivityRequest, Never>()
    let completeButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    var cellSubscriptions = Set<AnyCancellable>()
    
    private var activity = RecruitProfileActivityRequest()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Dropdown
    private var startDropdown: KoinDropdown?
    private var endDropdown: KoinDropdown?
    
    // MARK: - UI Components
    private let cardView = UIView()
    private let titleHeaderView = RecruitPostSectionHeaderView(
        title: "활동명",
        titleFont: .appFont(.pretendardSemiBold, size: 14),
        isRequired: true)
    private let deleteButton = UIButton(type: .system)
    private let titleTextField = UITextField()
    private let periodHeaderView = RecruitPostSectionHeaderView(
        title: "활동 기간",
        titleFont: .appFont(.pretendardSemiBold, size: 14),
        isRequired: true
    )
    private let activityPeriodDropdownAnchor = UIView()
    private let dateStackView = UIStackView()
    private let startDateButton = UIButton(type: .system)
    private let periodDashLabel = UILabel()
    private let endDateButton = UIButton(type: .system)
    private let ongoingButton = UIButton(type: .system)
    private let descriptionHeaderView = RecruitPostSectionHeaderView(
        title: "활동 내용",
        titleFont: .appFont(.pretendardSemiBold, size: 14),
        isRequired: true,
        limit: 1000
    )
    private let descriptionTextView = UITextView()
    private let descriptionPlaceholderLabel = UILabel()
    private let completeButton = StatefulButton(
        title: "완료",
        font: .appFont(.pretendardSemiBold, size: 14),
        enabledColor: .appColor(.new500),
        disabledColor: .appColor(.neutral400),
        enabledTextColor: .appColor(.neutral0),
        disabledTextColor: .appColor(.neutral0),
        cornerRadius: 16
    )
    private let startPickerView = KoinPickerDropDownView(
        delegate: KoinPickerDropDownViewDateDelegate(range: -18_250..<1)
    )
    private let endPickerView = KoinPickerDropDownView(
        delegate: KoinPickerDropDownViewDateDelegate(range: -18_250..<1)
    )
    
    // MARK: - Initializer
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cellSubscriptions.removeAll()
        startDropdown?.dismiss()
        endDropdown?.dismiss()
    }
    
    // MARK: - Public
    func prepareDropdown(host: KoinDropdownHost) {
        guard startDropdown == nil, endDropdown == nil else { return }
        startDropdown = host.makeDropdown(
            anchor: activityPeriodDropdownAnchor,
            contentView: startPickerView,
            configuration: .init(topPadding: 8, shadow: .shadow2)
        )
        endDropdown = host.makeDropdown(
            anchor: activityPeriodDropdownAnchor,
            contentView: endPickerView,
            configuration: .init(topPadding: 8, shadow: .shadow2)
        )
    }
    
    func configure(activity: RecruitProfileActivityRequest) {
        self.activity = activity
        titleTextField.text = activity.title
        descriptionTextView.text = activity.description
        descriptionPlaceholderLabel.isHidden = !(activity.description?.isEmpty ?? true)
        descriptionHeaderView.updateCounter(current: activity.description?.count ?? 0, limit: 1000)
        refreshDates()
        updateOngoingButton()
        updateCompleteButton()
    }
}

extension RecruitProfilePostActivityEditTableViewCell {
    private func bind() {
        startPickerView.selectedItemPublisher
            .sink { [weak self] item in
                guard let self, let date = date(from: item) else { return }
                activity.startedAt = date
                refreshDates()
                publishActivity()
            }
            .store(in: &subscriptions)
        endPickerView.selectedItemPublisher
            .sink { [weak self] item in
                guard let self, let date = date(from: item) else { return }
                activity.endedAt = date
                refreshDates()
                publishActivity()
            }
            .store(in: &subscriptions)
    }
}

extension RecruitProfilePostActivityEditTableViewCell {
    private func setAddTargets() {
        titleTextField.addTarget(self, action: #selector(titleEditingChanged), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(titleEditingDidEnd), for: .editingDidEnd)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        startDateButton.addTarget(self, action: #selector(startDateButtonTapped), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(endDateButtonTapped), for: .touchUpInside)
        ongoingButton.addTarget(self, action: #selector(ongoingButtonTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func titleEditingChanged() {
        activity.title = titleTextField.text
        publishActivity()
    }
    
    @objc private func titleEditingDidEnd() {
        let text = (titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        titleTextField.text = text
        activity.title = text
        publishActivity()
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonTappedPublisher.send()
    }
    
    @objc private func startDateButtonTapped() {
        endDropdown?.dismiss()
        endEditing(true)
        startPickerView.reset(initialDate: activity.startedAt ?? Date())
        startDropdown?.toggle()
    }
    
    @objc private func endDateButtonTapped() {
        guard !activity.isOngoing else { return }
        startDropdown?.dismiss()
        endEditing(true)
        endPickerView.reset(initialDate: activity.endedAt ?? activity.startedAt ?? Date())
        endDropdown?.toggle()
    }
    
    @objc private func ongoingButtonTapped() {
        activity.isOngoing.toggle()
        if activity.isOngoing {
            activity.endedAt = nil
            endDropdown?.dismiss()
        }
        updateOngoingButton()
        refreshDates()
        publishActivity()
    }
    
    @objc private func completeButtonTapped() {
        guard activity.isValid else { return }
        endEditing(true)
        completeButtonTappedPublisher.send()
    }
    
    private func publishActivity() {
        updateCompleteButton()
        activityChangedPublisher.send(activity)
    }
    
    private func refreshDates() {
        configureDateButton(
            startDateButton,
            date: activity.startedAt,
            placeholder: "시작일"
        )
        configureDateButton(
            endDateButton,
            date: activity.endedAt,
            placeholder: "종료일"
        )
        endDateButton.isEnabled = !activity.isOngoing
        endDateButton.alpha = activity.isOngoing ? 0.45 : 1
    }
}

extension RecruitProfilePostActivityEditTableViewCell {
    private func configureDateButton(
        _ button: UIButton,
        date: Date?,
        placeholder: String
    ) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter
        }()
        
        let text = date.map(dateFormatter.string(from:)) ?? placeholder
        button.setAttributedTitle(NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor: UIColor.appColor(date == nil ? .neutral500 : .neutral800)
            ]
        ), for: .normal)
    }
    
    private func updateOngoingButton() {
        ongoingButton.isSelected = activity.isOngoing
        ongoingButton.setNeedsUpdateConfiguration()
    }
    
    private func updateCompleteButton() {
        completeButton.updateState(isEnabled: activity.isValid)
    }
    
    private func date(from item: [String]) -> Date? {
        guard item.count == 3,
              let year = Int(item[0].filter(\.isNumber)),
              let month = Int(item[1].filter(\.isNumber)),
              let day = Int(item[2].filter(\.isNumber)) else { return nil }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }
}

extension RecruitProfilePostActivityEditTableViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
        
        updateOngoingButton()
        updateCompleteButton()
    }
    private func setUpStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        descriptionTextView.delegate = self
        
        cardView.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
        }
        deleteButton.do {
            $0.setImage(UIImage.appImage(asset: .newCancel)?.resize(to: CGSize(width: 20, height: 20)), for: .normal)
            $0.tintColor = .appColor(.neutral800)
        }
        titleTextField.do {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
            $0.leftViewMode = .always
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
            $0.rightViewMode = .always
            $0.attributedPlaceholder = NSAttributedString(
                string: "활동명을 입력해주세요.",
                attributes: [.foregroundColor: UIColor.appColor(.neutral500)]
            )
        }
        dateStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }
        activityPeriodDropdownAnchor.do {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = false
        }
        [startPickerView, endPickerView].forEach {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
        }
        [startDateButton, endDateButton].forEach {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.contentHorizontalAlignment = .center
        }
        periodDashLabel.do {
            $0.text = "-"
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral700)
            $0.textAlignment = .center
        }
        ongoingButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "진행 중",
                attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor: UIColor.appColor(.neutral800)
                ])
            )
            configuration.imagePlacement = .leading
            configuration.imagePadding = 4
            configuration.contentInsets = .zero
            configuration.automaticallyUpdateForSelection = false
            configuration.background.backgroundColor = .clear
            configuration.baseBackgroundColor = nil
            $0.configuration = configuration
            $0.contentHorizontalAlignment = .leading
            $0.configurationUpdateHandler = { button in
                let asset: ImageAsset = button.isSelected
                ? .circleCheckedPrimary500
                : .circlePrimary500
                var configuration = button.configuration
                configuration?.image = UIImage.appImage(asset: asset)?
                    .withTintColor(.appColor(.new500), renderingMode: .alwaysOriginal)
                button.configuration = configuration
            }
        }
        descriptionTextView.do {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            $0.textContainer.lineFragmentPadding = 0
        }
        descriptionPlaceholderLabel.do {
            $0.text = "활동 내용을 간단히 작성해주세요."
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral500)
        }
    }
    
    private func setUpLayouts() {
        [startDateButton, periodDashLabel, endDateButton, ongoingButton].forEach {
            dateStackView.addArrangedSubview($0)
        }
        [titleHeaderView, deleteButton, titleTextField, periodHeaderView,
         activityPeriodDropdownAnchor, dateStackView,
         descriptionHeaderView, descriptionTextView, descriptionPlaceholderLabel,
         completeButton].forEach {
            cardView.addSubview($0)
        }
        [cardView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        startDateButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        endDateButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        cardView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(44)
        }
        titleHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(deleteButton.snp.leading)
        }
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(titleHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        periodHeaderView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        dateStackView.snp.makeConstraints {
            $0.top.equalTo(periodHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
        activityPeriodDropdownAnchor.snp.makeConstraints {
            $0.edges.equalTo(dateStackView)
        }
        startDateButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        endDateButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        startDateButton.snp.makeConstraints {
            $0.width.equalTo(endDateButton)
        }
        periodDashLabel.snp.makeConstraints {
            $0.width.equalTo(8)
        }
        ongoingButton.snp.makeConstraints {
            $0.width.equalTo(70)
        }
        descriptionHeaderView.snp.makeConstraints {
            $0.top.equalTo(dateStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(106)
        }
        descriptionPlaceholderLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView).offset(8)
            $0.leading.trailing.equalTo(descriptionTextView).inset(12)
        }
        completeButton.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(40)
        }
    }
}

extension RecruitProfilePostActivityEditTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = String(textView.text.prefix(1000))
        textView.text = text
        descriptionPlaceholderLabel.isHidden = !text.isEmpty
        descriptionHeaderView.updateCounter(current: text.count, limit: 1000)
        activity.description = text
        publishActivity()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = String(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1000))
        textView.text = text
        descriptionPlaceholderLabel.isHidden = !text.isEmpty
        descriptionHeaderView.updateCounter(current: text.count, limit: 1000)
        activity.description = text
        publishActivity()
    }
}
