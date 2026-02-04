//
//  LostItemListFilterButton.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit

final class LostItemListFilterButton: UIButton {
    
    // MARK: - Properties
    let text: String
    
    // MARK: - Initializer
    init(text: String, isSelected: Bool) {
        self.text = text
        super.init(frame: .zero)
        configureView()
        self.isSelected = isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            let borderColor = isSelected ? UIColor.appColor(.primary500).cgColor : UIColor.appColor(.neutral300).cgColor
            layer.borderColor = borderColor
        }
    }
    
    private func configureView() {
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            .foregroundColor : UIColor.appColor(.neutral500),
            .font : UIFont.appFont(.pretendardBold, size: 14)
        ]), for: .normal)
        setAttributedTitle(NSAttributedString(string: text, attributes: [
            .foregroundColor : UIColor.appColor(.primary500),
            .font : UIFont.appFont(.pretendardBold, size: 14)
        ]), for: .selected)
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .white
        self.configuration = configuration
        
        backgroundColor = .appColor(.neutral0)
        
        layer.borderWidth = 1
        layer.cornerRadius = 17
        clipsToBounds = true
    }
}
