//
//  PointLabel.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import UIKit

final class PointLabel: UIView {
    
    private let starLabel = UILabel().then {
        $0.text = "✱"
        $0.textColor = UIColor.appColor(.sub500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 10)
    }
    
    private let mainLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
    }
    
    // MARK: - Initializers
    init(text: String) {
        super.init(frame: .zero)
        mainLabel.text = text
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        addSubview(starLabel)
        addSubview(mainLabel)
        
        starLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(4)
            make.leading.equalTo(starLabel.snp.trailing).offset(2)
        }
    }
    
    func setText(text: String) {
        mainLabel.text = text
    }
    
    func getText() -> String {
        return mainLabel.text ?? ""
    }

}
