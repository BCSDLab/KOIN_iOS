//
//  GuideLabel.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import UIKit

final class GuideLabel: UIView {
    
    // MARK: - UI Components
    
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.neutral500)
        label.font = UIFont.appFont(.pretendardRegular, size: 15)
        return label
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.appFont(.pretendardRegular, size: 15)
        return label
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        leftLabel.text = text
    }
    
    func configure(text: String) {
        rightLabel.text = text
    }
}

// MARK: UI Settings

extension GuideLabel {
    private func setUpLayOuts() {
        [leftLabel, rightLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        leftLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading)
        }
        rightLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(leftLabel.snp.trailing).offset(8.19)
            make.trailing.lessThanOrEqualTo(self.snp.trailing).offset(-8.19)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}

