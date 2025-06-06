//
//  BusSearchDatePickerViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/17/24.
//

import Combine
import UIKit

final class BusSearchDatePickerViewController: ModalViewController {
   
    private let pickerView = KoinPickerView()
    private var subscriptions: Set<AnyCancellable> = []
    let pickerSelectedItemsPublisher = CurrentValueSubject<[String], Never>([])
    let changePickerDate = PassthroughSubject<Bool?, Never>()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewInContainer(view: pickerView, frame: .init(x: 0, y: 0, width: 301, height: 122))
        
        rightButtonPublisher.sink { [weak self] in
            self?.pickerSelectedItemsPublisher.send(self?.pickerView.selectedItemPublisher.value ?? [])
            self?.changePickerDate.send(self?.pickerView.changeSelectedItemPublisher.value)
            self?.pickerView.changeSelectedItemPublisher.send(nil)
        }.store(in: &subscriptions)
        configureView()
        
        leftButtonPublisher.sink { [weak self] in
            let currentDate = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: currentDate)
            let minute = calendar.component(.minute, from: currentDate)
            let amPm = hour < 12 ? "오전" : "오후"
            let adjustedHour = hour % 12
            let displayHour = adjustedHour == 0 ? 12 : adjustedHour
            
            let pickerSelectedItems = ["오늘", amPm, String(displayHour), String(format: "%02d", minute)]
            self?.pickerView.setSelectedData(selectedItem: pickerSelectedItems)
            self?.pickerSelectedItemsPublisher.send(pickerSelectedItems)
            self?.pickerView.changeSelectedItemPublisher.send(nil)
        }.store(in: &subscriptions)
    }
    
    func setPickerItems(items: [[String]], selectedItems: [String]) {
        pickerView.changeSelectedItemPublisher.send(nil)
        pickerView.setPickerData(items: items, selectedItem: selectedItems)
    }
    
    private func configureView() {
        updateMessageLabel(alignment: .left)
        updateSubMessageLabel(alignment: .left)
        updaterightButton(borderWidth: 0, title: "완료")
        updateCloseButton(borderWidth: 0, title: "지금 출발")
    }
}
