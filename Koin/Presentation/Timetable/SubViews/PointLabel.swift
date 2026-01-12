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
            make.centerY.equalTo(self.snp.top)
            make.trailing.equalTo(self.snp.leading)
        }
        mainLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setText(text: String) {
        mainLabel.text = text
    }
    
    func getText() -> String {
        return mainLabel.text ?? ""
    }

}
