//
//  EditLostItemButton.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit

final class EditLostItemButton: UIButton {
    
    let title: String
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .appColor(.neutral0) : .appColor(.primary500)
            setAttributedTitle(NSAttributedString(string: title, attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : (isSelected ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral0))
            ]), for: .normal)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let width = super.intrinsicContentSize.width + 24
        let height = super.intrinsicContentSize.height
        return CGSize(width: width, height: height)
    }
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        layer.cornerRadius = 19
        layer.borderWidth = 1
        layer.borderColor = UIColor.appColor(.primary500).cgColor
    }
}
