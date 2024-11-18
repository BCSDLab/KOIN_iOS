



















































































































































































































































































































































































































































//
//  CustomPickerView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/11/24.
//

import Combine
import Foundation
import SnapKit
import UIKit

final class KoinPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Properties
    private var items: [[String]] = [[]]
    private var selectedItem: [String] = []
    let selectedItemPublisher = PassthroughSubject<[String], Never>()
    private var font: UIFont
    private var selectedColor: UIColor
    private var deselectedColor: UIColor
    
    // MARK: - UI Components
    private let pickerView = UIPickerView(frame: .zero)
    
    // MARK: - Initialization
    init(font: UIFont = .appFont(.pretendardMedium, size: 16), selectedColor: UIColor = .appColor(.primary500), deselectedColor: UIColor = .appColor(.neutral800)) {
        self.font = font
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedItem = []
        self.items = [[]]
        self.font = .appFont(.pretendardMedium, size: 13)
        self.selectedColor = .appColor(.primary500)
        self.deselectedColor = .appColor(.neutral500)
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews() 
        
        for subview in pickerView.subviews {
            subview.backgroundColor = .clear
        }
    }
    
    private func setup() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        setUpPickerLayouts()
    }
    
    private func setUpPickerLayouts() {
        self.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setPickerData(items: [[String]], selectedItem: [String]) {
        self.items = items
        self.selectedItem = selectedItem
        if items.count == selectedItem.count {
            for idx in 0..<selectedItem.count {
                if let row = items[idx].firstIndex(of: selectedItem[idx]) {
                    pickerView.selectRow(row, inComponent: idx, animated: false)
                }
            }
        }
        pickerView.reloadAllComponents()
    }
}

extension KoinPickerView {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem[component] = items[component][row]
        selectedItemPublisher.send(selectedItem)
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = items[component][row]
        let attributes: [NSAttributedString.Key: Any]
        
        if pickerView.selectedRow(inComponent: component) == row {
            attributes = [
                .foregroundColor: selectedColor,
                .font: self.font
            ]
        } else {
            attributes = [
                .foregroundColor: deselectedColor,
                .font: self.font
            ]
        }
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.frame.height / 3 - 10
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 100
        case 1:
            return 65
        default:
            return 35
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: self.frame.height))
        
        let label = UILabel()
        label.frame = containerView.bounds
        label.textAlignment = .center
        label.font = font
        
        label.text = items[component][row]
        if pickerView.selectedRow(inComponent: component) == row {
            label.textColor = selectedColor
        } else {
            label.textColor = deselectedColor
        }
        
        if component == 0 {
            label.textAlignment = .right
        }
        label.backgroundColor = .clear
        containerView.addSubview(label)
        containerView.backgroundColor = .clear
        return containerView
    }
}
