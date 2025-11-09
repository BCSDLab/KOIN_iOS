//
//  RadioButtonGroup.swift
//  koin
//
//  Created by 이은지 on 11/9/25.
//

import Foundation

final class RadioButtonGroup {
    
    private var radioButtons: [RadioButton] = []
    var selectedButton: RadioButton?
    
    var onSelectionChanged: ((RadioButton?) -> Void)?
    
    func addButton(_ button: RadioButton) {
        radioButtons.append(button)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .valueChanged)
    }
    
    @objc private func buttonTapped(_ button: RadioButton) {
        if button.isSelected {
            radioButtons.forEach {
                if $0 != button {
                    $0.isSelected = false
                }
            }
            selectedButton = button
        } else {
            if selectedButton == button {
                selectedButton = nil
            }
        }
        onSelectionChanged?(selectedButton)
    }
    
    func deselectAll() {
        radioButtons.forEach { $0.isSelected = false }
        selectedButton = nil
    }
}
