//
//  SelectTimeView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class SelectTimeView: UIView {
    
    enum Size {
        case small
        case big
    }
    
    // MARK: - Properties
    let selectionChangedPublisher = PassthroughSubject<Void, Never>()
    /// 요일 드롭다운은 시트 밖 메인 VC가 띄워야 화면 기준으로 방향이 정해진다.
    let weekdayDropdownPublisher = PassthroughSubject<(anchor: UIView, content: UIView & KoinDropdownContentView), Never>()
    
    var selectedDay: String {
        TimetableButtonTitle.text(on: selectWeekButton) ?? "월요일"
    }

    var selectedTime: String {
        TimetableButtonTitle.text(on: startTimeButton) ?? "09:00"
    }

    var endedTime: String {
        TimetableButtonTitle.text(on: endTimeButton) ?? "10:00"
    }

    var dayIndex: Int { ["월요일", "화요일", "수요일", "목요일", "금요일"].firstIndex(of: selectedDay) ?? 0 }
    var startMinute: Int { Self.minutes(from: selectedTime) ?? 540 }
    var endMinute: Int { Self.minutes(from: endedTime) ?? 600 }

    // MARK: - UI Components
    private let timeLabel = PointLabel(text: "시간").then { _ in
    }
    private let selectWeekButton = UIButton()
    private let startTimeButton = TimetableTimeButton(type: .custom)
    private let separateLabel = UILabel()
    private let endTimeButton = TimetableTimeButton(type: .custom)
    private let rowStackView = UIStackView()

    func configure(row: AddDirectCollectionView.Row) {
        let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일"]
        setButtonTitle(weekdays.indices.contains(row.day) ? weekdays[row.day] : weekdays[0], on: selectWeekButton)
        setButtonTitle(Self.timeText(row.startMinute), on: startTimeButton)
        setButtonTitle(Self.timeText(row.endMinute), on: endTimeButton)
    }

    private static func timeText(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    private static func minutes(from time: String) -> Int? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return parts[0] * 60 + parts[1]
    }

    init(frame: CGRect, size: Size) {
        super.init(frame: frame)
        configureView()
        selectWeekButton.addTarget(self, action: #selector(didTapSelectWeek), for: .touchUpInside)
        startTimeButton.addTarget(self, action: #selector(didTapStartTime), for: .touchUpInside)
        endTimeButton.addTarget(self, action: #selector(didTapEndTime), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SelectTimeView {
    @objc private func didTapSelectWeek() {
        let contentView = TimetableWeekdayDropdownView(selectedDay: selectedDay) { [weak self] day in
            guard let self else { return }
            self.setButtonTitle(day, on: self.selectWeekButton)
            self.selectionChangedPublisher.send()
        }
        weekdayDropdownPublisher.send((selectWeekButton, contentView))
    }

    @objc private func didTapStartTime() {
        showTimePicker(for: startTimeButton, title: "시작시간을 선택해주세요.")
    }

    @objc private func didTapEndTime() {
        showTimePicker(for: endTimeButton, title: "종료시간을 선택해주세요.")
    }

    private func showTimePicker(for button: UIButton, title: String) {
        guard let viewController = owningViewController,
              viewController.presentedViewController == nil else { return }
        viewController.view.endEditing(true)
        let contentView = TimetableTimePickerContentView(title: title, time: TimetableButtonTitle.text(on: button) ?? "09:00")
        let modal = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .custom(customView: contentView),
            button: .buttons(
                leftButtonTitle: "취소",
                leftButtonStyle: .init(textColor: .neutral600, font: .pretendardMedium, fontSize: 15, borderColor: .gray, borderWidth: 1, cornerRadius: 4),
                rightButtonTitle: "확인",
                rightButtonAction: { [weak self, weak button] in
                    guard let self, let button else { return }
                    self.setButtonTitle(contentView.selectedTime, on: button)
                    self.selectionChangedPublisher.send()
                },
                rightButtonStyle: .init(textColor: .neutral0, font: .pretendardMedium, fontSize: 15, backgroundColor: .new500, cornerRadius: 4)
            ),
            layout: .init(width: 300, contentTopPadding: 24, contentHorizontalPadding: 32, paddingBetweenContentAndButton: 13, buttonHorizontalPadding: 32, buttonBottomPadding: 24)
        ))
        viewController.present(modal, animated: true)
    }

    private var owningViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}

extension SelectTimeView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.distribution = .equalSpacing
        for (button, title, asset) in [
            (selectWeekButton, "월요일", ImageAsset.timetableChevronDown),
            (startTimeButton, "09:00", ImageAsset.timetableUpDownArrow),
            (endTimeButton, "10:00", ImageAsset.timetableUpDownArrow)
        ] {
            button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            button.layer.borderWidth = 0.5
            button.layer.cornerRadius = 16
            var configuration = UIButton.Configuration.plain()
            configuration.image = .appImage(asset: asset)
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 4
            configuration.baseForegroundColor = .appColor(.neutral800)
            configuration.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: button === selectWeekButton ? 0 : 6)
            button.configuration = configuration
            setButtonTitle(title, on: button)
        }
        separateLabel.text = "~"
        separateLabel.font = .appFont(.pretendardMedium, size: 18)
        separateLabel.textColor = .appColor(.neutral800)
        separateLabel.textAlignment = .center
    }

    private func setButtonTitle(_ title: String, on button: UIButton) {
        TimetableButtonTitle.set(title, on: button, font: .pretendardSemiBold, size: 12, color: .neutral800)
    }

    private func setUpLayouts() {
        addSubview(rowStackView)
        [timeLabel, selectWeekButton, startTimeButton, separateLabel, endTimeButton].forEach { rowStackView.addArrangedSubview($0) }
    }

    private func setUpConstraints() {
        rowStackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        timeLabel.snp.makeConstraints { $0.width.equalTo(48) }
        [selectWeekButton, startTimeButton, endTimeButton].forEach { button in
            button.snp.makeConstraints {
                $0.width.equalTo(74)
                $0.height.equalTo(35)
            }
        }
    }
}


private final class TimetableTimeButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        // 원본 SVG는 좌우 경로이므로 이미지 뷰가 배치된 뒤 위아래 방향을 적용한다.
        imageView?.transform = CGAffineTransform(rotationAngle: -.pi / 2)
    }
}

private final class TimetableWeekdayDropdownView: UIView, KoinDropdownContentView {
    // MARK: - Properties
    private let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일"]
    private let dismissSubject = PassthroughSubject<Void, Never>()
    private let onSelect: (String) -> Void
    private let selectedDay: String

    var dismissTappedPublisher: AnyPublisher<Void, Never> {
        dismissSubject.eraseToAnyPublisher()
    }

    var height: CGFloat { CGFloat(weekdays.count) * 35 }

    // MARK: - UI Components
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []

    init(selectedDay: String, onSelect: @escaping (String) -> Void) {
        self.selectedDay = selectedDay
        self.onSelect = onSelect
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func weekdayTapped(_ sender: UIButton) {
        onSelect(weekdays[sender.tag])
        dismissSubject.send()
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 8
        clipsToBounds = true
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        buttons = weekdays.enumerated().map { index, day in
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(day, for: .normal)
            button.setTitleColor(.appColor(.neutral800), for: .normal)
            button.titleLabel?.font = .appFont(.pretendardSemiBold, size: 12)
            button.accessibilityTraits = day == selectedDay ? [.button, .selected] : .button
            button.addTarget(self, action: #selector(weekdayTapped(_:)), for: .touchUpInside)
            return button
        }
    }

    private func setUpLayouts() {
        addSubview(stackView)
        buttons.forEach { stackView.addArrangedSubview($0) }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

private final class TimetableTimePickerContentView: UIView {
    // MARK: - Properties
    private let referenceDay: Date

    var selectedTime: String {
        // time24h의 다음날 자정을 DateFormatter의 00:00 대신 24:00으로 보존한다.
        let minutes = Calendar.koin.dateComponents([.minute], from: referenceDay, to: pickerView.date).minute ?? 540
        return String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let pickerView: KoinPickerView
    private let colonLabel = UILabel()

    init(title: String, time: String) {
        var configuration = KoinPickerView.Configuration.timetable
        configuration.style = .new
        let pickerView = KoinPickerView(configuration: configuration)
        self.pickerView = pickerView
        referenceDay = Calendar.koin.startOfDay(for: pickerView.date)
        super.init(frame: .zero)
        titleLabel.text = title
        let components = time.split(separator: ":").compactMap { Int($0) }
        let minutes = components.count == 2 ? components[0] * 60 + components[1] : 540
        if let date = Calendar.koin.date(byAdding: .minute, value: minutes, to: referenceDay) {
            pickerView.setDate(date, animated: false)
        }
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        titleLabel.font = .appFont(.pretendardSemiBold, size: 16)
        titleLabel.textColor = .appColor(.neutral800)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        colonLabel.text = ":"
        colonLabel.font = .appFont(.pretendardMedium, size: 16)
        colonLabel.textColor = .appColor(.new500)
    }

    private func setUpLayouts() {
        [titleLabel, pickerView, colonLabel].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
        pickerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.centerX.bottom.equalToSuperview()
            $0.width.equalTo(126)
        }
        colonLabel.snp.makeConstraints {
            $0.centerX.equalTo(pickerView)
            // 버스 시간 모달과 같이 글자 기준선 보정으로 1pt 올린다.
            $0.centerY.equalTo(pickerView).offset(-1)
        }
    }
}
