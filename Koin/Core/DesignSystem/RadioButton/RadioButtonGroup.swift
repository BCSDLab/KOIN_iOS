//
//  RadioButtonGroup.swift
//  koin
//
//  Created by 이은지 on 11/24/25.
//

import Foundation

final class RadioButtonGroup {
    
    // MARK: - Properties
    
    private var radiobuttons: [RadioButton] = []
    
    private(set) var selectedRadioButton: RadioButton? {
        didSet {
            onSelectionChanged?(selectedRadioButton)
        }
    }
    
    var onSelectionChanged: ((RadioButton?) -> Void)?
        
    func addRadioButton(_ button: RadioButton) {
        guard !radiobuttons.contains(where: { $0 === button }) else { return }
        
        radiobuttons.append(button)
        button.group = self
        button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .valueChanged)
        
        if selectedRadioButton != nil {
            button.isSelected = false
        } else if button.isSelected {
            selectedRadioButton = button
        }
    }
    
    func removeRadioButton(_ button: RadioButton) {
        guard let index = radiobuttons.firstIndex(where: { $0 === button }) else { return }
        
        radiobuttons.remove(at: index)
        button.group = nil
        button.removeTarget(self, action: #selector(radioButtonTapped(_:)), for: .valueChanged)
        
        if selectedRadioButton === button {
            selectedRadioButton = nil
        }
    }
    
    func removeAllRadioButtons() {
        radiobuttons.forEach { button in
            button.group = nil
            button.removeTarget(self, action: #selector(radioButtonTapped(_:)), for: .valueChanged)
        }
        radiobuttons.removeAll()
        selectedRadioButton = nil
    }
    
    func selectRadioButton(_ button: RadioButton) {
        guard radiobuttons.contains(where: { $0 === button }), button.isEnabled else { return }
        
        selectedRadioButton?.isSelected = false
        
        button.isSelected = true
        selectedRadioButton = button
    }
    
    func deselectAllRadioButtons() {
        selectedRadioButton?.isSelected = false
        selectedRadioButton = nil
    }
    
    func setEnabledRadioButton(_ enabled: Bool) {
        radiobuttons.forEach { $0.isEnabled = enabled }
    }
        
    @objc private func radioButtonTapped(_ sender: RadioButton) {
        selectRadioButton(sender)
    }
}
