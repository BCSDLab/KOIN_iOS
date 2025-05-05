//
//  PossibleLabel.swift
//  Koin
//
//  Created by 김나훈 on 3/13/24.
//

import UIKit

final class PossibilityLabel: UIView {
    
    // MARK: - UI Components
    private let innerLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral0)
        $0.font = UIFont.appFont(.pretendardMedium, size: 13)
    }
    
    private let outerImageView = UIImageView().then { _ in
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(text: String, image: UIImage?) {
        innerLabel.text = text
        outerImageView.image = image
    }
}
 
// MARK: UI Settings
extension PossibilityLabel {
    private func setUpLayOuts() {
        addSubview(outerImageView)
        addSubview(innerLabel)
    }
    
    private func setUpConstraints() {
        innerLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
        outerImageView.snp.makeConstraints { make in
            make.centerX.equalTo(innerLabel.snp.centerX)
            make.centerY.equalTo(innerLabel.snp.centerY)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
