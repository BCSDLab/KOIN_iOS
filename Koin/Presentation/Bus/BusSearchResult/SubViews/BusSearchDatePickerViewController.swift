//
//  BusSearchDatePickerViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/17/24.
//

import UIKit

final class BusSearchDatePickerViewController: KoinModalViewController {
    
    // MARK: - Properties
    private let onPickerDateChanged: (Bool?) -> Void
    private let onPickerItemsSelected: ([String]) -> Void
    private let onDepartureNowTapped: ()->Void
    
    // MARK: - UI Components
    private let customView = UIView()
    private let mainTitleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let pickerView = KoinPickerView()
    
    // MARK: - Initializer
    init(
        subTitle: String,
        onPickerDateChanged: @escaping (Bool?) -> Void,
        onPickerItemsSelected: @escaping ([String]) -> Void,
        onDepartureNowTapped: @escaping ()->Void
    ) {
        self.onPickerDateChanged = onPickerDateChanged
        self.onPickerItemsSelected = onPickerItemsSelected
        self.onDepartureNowTapped = onDepartureNowTapped
        
        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: customView),
            button: .buttons(
                leftButtonTitle: "지금 출발",
                leftButtonStyle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15
                ),
                rightButtonTitle: "완료",
                rightButtonAction: {}
            ),
            layout: .init(
                contentTopPadding: 24,
                contentHorizontalPadding: 0
            )
        ))
        
        configureSubTitleLabel(subTitle)
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - Public
    func setPickerItems(items: [[String]], selectedItems: [String]) {
        pickerView.changeSelectedItemPublisher.send(nil)
        pickerView.setPickerData(items: items, selectedItem: selectedItems)
    }
    
    // MARK: - Override
    override func leftButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            let currentDate = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: currentDate)
            let minute = calendar.component(.minute, from: currentDate)
            let amPm = hour < 12 ? "오전" : "오후"
            let adjustedHour = hour % 12
            let displayHour = adjustedHour == 0 ? 12 : adjustedHour
            
            let selectedItems = ["오늘", amPm, String(displayHour), String(format: "%02d", minute)]
            pickerView.setSelectedData(selectedItem: selectedItems)
            onPickerItemsSelected(selectedItems)
            pickerView.changeSelectedItemPublisher.send(nil)
            
            onDepartureNowTapped()
        }
    }
    
    override func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onPickerItemsSelected(pickerView.selectedItemPublisher.value)
            onPickerDateChanged(pickerView.changeSelectedItemPublisher.value)
            pickerView.changeSelectedItemPublisher.send(nil)
        }
    }
}

extension BusSearchDatePickerViewController {
    
    private func configureSubTitleLabel(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.do {
            $0.alignment = .left
            $0.lineSpacing = 14 * 0.6
            $0.lineBreakStrategy = .hangulWordPriority
        }
        subTitleLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral500),
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .paragraphStyle: paragraphStyle,
            ]
        )
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        mainTitleLabel.do {
            $0.text = "출발 시각 설정"
            $0.textColor = .appColor(.neutral700)
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.numberOfLines = 1
            $0.textAlignment = .left
        }
        subTitleLabel.do {
            $0.numberOfLines = 2
        }
        pickerView.do {
            $0.backgroundColor = .appColor(.neutral50)
        }
    }
    
    private func setUpLayouts() {
        [mainTitleLabel, subTitleLabel, pickerView].forEach {
            customView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(29)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(mainTitleLabel)
            $0.height.equalTo(44)
        }
        pickerView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        customView.snp.makeConstraints {
            $0.width.equalTo(301)
            $0.height.equalTo(227)
        }
    }
}
