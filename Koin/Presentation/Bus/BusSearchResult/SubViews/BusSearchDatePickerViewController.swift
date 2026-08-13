//
//  BusSearchDatePickerViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/17/24.
//

import UIKit

final class BusSearchDatePickerViewController: ModalViewController {
    
    // MARK: - Properties
    private let onDepartureNowTapped: () -> Void
    private let onPickerDateChanged: (Bool?) -> Void
    private let onPickerItemsSelected: ([String]) -> Void
    
    // MARK: - UI Components
    private let pickerView = KoinPickerView()
    
    // MARK: - Initializer
    init(
        onDepartureNowTapped: @escaping () -> Void,
        onPickerDateChanged: @escaping (Bool?) -> Void,
        onPickerItemsSelected: @escaping ([String]) -> Void,
        width: CGFloat,
        height: CGFloat,
        paddingBetweenLabels: CGFloat,
        title: String,
        subTitle: String,
        titleColor: UIColor,
        subTitleColor: UIColor
    ) {
        self.onDepartureNowTapped = onDepartureNowTapped
        self.onPickerDateChanged = onPickerDateChanged
        self.onPickerItemsSelected = onPickerItemsSelected
        super.init(
            onLeftButtonTapped: nil,
            onRightButtonTapped: {},
            width: width,
            height: height,
            paddingBetweenLabels: paddingBetweenLabels,
            title: title,
            subTitle: subTitle,
            titleColor: titleColor,
            subTitleColor: subTitleColor
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewInContainer(view: pickerView, frame: .init(x: 0, y: 0, width: 301, height: 122))
        configureView()
    }
    
    override func rightButtonTapped() {
        let selectedItems = pickerView.selectedItemPublisher.value
        onPickerItemsSelected(selectedItems)
        onPickerDateChanged(pickerView.changeSelectedItemPublisher.value)
        pickerView.changeSelectedItemPublisher.send(nil)
        dismissWithAnimation()
    }
    
    override func closeButtonTapped() {
        onDepartureNowTapped()
        
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
        dismissWithAnimation()
    }

    // MARK: - Public
    func setPickerItems(items: [[String]], selectedItems: [String]) {
        pickerView.changeSelectedItemPublisher.send(nil)
        pickerView.setPickerData(items: items, selectedItem: selectedItems)
    }
}

extension BusSearchDatePickerViewController {
    // MARK: - Configure
    private func configureView() {
        updateMessageLabel(alignment: .left)
        updateSubMessageLabel(alignment: .left)
        updaterightButton(borderWidth: 0, title: "완료")
        updateCloseButton(borderWidth: 0, title: "지금 출발")
    }
}
