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
    let pickerSelectedItemsPublisher = PassthroughSubject<[String], Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewInContainer(view: pickerView, frame: .init(x: 0, y: 0, width: 301, height: 122))

        pickerView.selectedItemPublisher.sink { [weak self] selectedItems in
            print(selectedItems)
            self?.pickerSelectedItemsPublisher.send(selectedItems)
        }.store(in: &subscriptions)
    }

    func setPickerItems(items: [[String]], selectedItems: [String]) {
        pickerView.setPickerData(items: items, selectedItem: selectedItems)
    }
}
