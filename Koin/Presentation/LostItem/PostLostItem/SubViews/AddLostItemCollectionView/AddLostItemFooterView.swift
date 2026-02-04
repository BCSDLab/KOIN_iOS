//
//  AddLostItemFooterView.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostItemFooterView: UICollectionReusableView {
    
    static let identifier = "AddLostItemFooterView"
    let addItemButtonPublisher = PassthroughSubject<Void, Never>()
    let shouldDismissDropDownPublisher = PassthroughSubject<Void, Never>()
    
    private let addItemButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .addCircle)
        var text = AttributedString("물품 추가")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addItemButton.addTarget(self, action: #selector(addItemButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddLostItemFooterView {
    @objc private func addItemButtonTapped() {
        addItemButtonPublisher.send()
        shouldDismissDropDownPublisher.send()
        self.endEditing(true)
    }
    
}
extension AddLostItemFooterView {
    private func setupViews() {
        self.backgroundColor = .systemBackground
        
        [addItemButton].forEach {
            self.addSubview($0)
        }
        addItemButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(100)
            make.height.equalTo(38)
        }
    }
}
