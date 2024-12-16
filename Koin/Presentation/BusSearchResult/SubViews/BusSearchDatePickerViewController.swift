//
//  BusSearchDatePickerViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/17/24.
//

import Combine
import UIKit

final class BusSearchDatePickerViewController: LoginModalViewController {
   
    private let pickerView = KoinPickerView()
    private var subscriptions: Set<AnyCancellable> = []
    let pickerSelectedItemsPublisher = CurrentValueSubject<[String], Never>([])
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewInContainer(view: pickerView, frame: .init(x: 0, y: 0, width: 301, height: 122))
        
        loginButtonPublisher.sink { [weak self] in
            self?.pickerSelectedItemsPublisher.send(self?.pickerView.selectedItemPublisher.value ?? [])
        }.store(in: &subscriptions)
    }
    
    func setPickerItems(items: [[String]], selectedItems: [String]) {
        pickerView.setPickerData(items: items, selectedItem: selectedItems)
    }
}
