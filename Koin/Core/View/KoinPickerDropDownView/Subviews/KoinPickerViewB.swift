//
//  CallVanTimePickerDropDownView.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import UIKit
import Combine
import SnapKit

final class KoinPickerViewB: UIView {
    
    // MARK: - Publisher
    let selectedItemPublisher = PassthroughSubject<[String], Never>()
    
    // MARK: - Properties
    private var font: UIFont
    private var selectedColor: UIColor
    private var deselectedColor: UIColor
    private var columnSpacing: CGFloat
    
    private var items: [[String]] = []
    private(set) var selectedItem: [String] = []
    private var columnWidths: [CGFloat] = []
    
    // MARK: - UI Components
    private let pickerView = UIPickerView(frame: .zero)
    
    // MARK: - Initializer
    init(
        font: UIFont = .appFont(.pretendardMedium, size: 16),
        selectedColor: UIColor = .appColor(.neutral800),
        deselectedColor: UIColor = .appColor(.neutral500),
        columnSpacing: CGFloat
    ) {
        self.font = font
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        self.columnSpacing = columnSpacing
        
        super.init(frame: .zero)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in pickerView.subviews {
            subview.backgroundColor = .clear
        }
    }
    
    // MARK: - Public
    func reset(items: [[String]], selectedItem: [String], columnWidths: [CGFloat]) {
        guard items.count == selectedItem.count, selectedItem.count == columnWidths.count else {
            assert(false)
            return
        }
        self.items = items
        self.selectedItem = selectedItem
        self.columnWidths = columnWidths
        reloadPicker()
    }
    
    func update(selectedItem: [String]) {
        guard items.count == selectedItem.count, selectedItem.count == columnWidths.count else {
            assert(false)
            return
        }
        self.selectedItem = selectedItem
        reloadPicker()
    }
}

extension KoinPickerViewB {
    
    private func reloadPicker() {
        pickerView.reloadAllComponents()
        for index in 0..<selectedItem.count {
            if let row = items[index].firstIndex(of: selectedItem[index]) {
                pickerView.selectRow(row, inComponent: index, animated: false)
            }
        }
//        selectedItemPublisher.send(selectedItem)
    }
    
    private func configureView() {
        [pickerView].forEach {
            addSubview($0)
        }
        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension KoinPickerViewB: UIPickerViewDataSource {
    
    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return items.count
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return items[component].count
    }
}

extension KoinPickerViewB: UIPickerViewDelegate {
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        selectedItem[component] = items[component][row]
        selectedItemPublisher.send(selectedItem)
        pickerView.reloadComponent(component)
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        rowHeightForComponent component: Int
    ) -> CGFloat {
        return pickerView.bounds.height / 3
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        widthForComponent component: Int
    ) -> CGFloat {
        
        return columnWidths[component] + columnSpacing
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        
        let label = (view as? UILabel) ?? UILabel()
        label.do {
            $0.textAlignment = .center
            $0.font = font
            $0.text = items[component][row]
            $0.backgroundColor = .clear
            $0.textColor = selectedItem[component] == items[component][row] ? selectedColor : deselectedColor
        }
        return label
    }
}
