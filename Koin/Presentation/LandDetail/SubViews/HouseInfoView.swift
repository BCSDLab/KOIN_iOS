//
//  HouseInfoView.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import UIKit

final class HouseInfoView: UIView {
    
    // MARK: - UI Components
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.textColor = UIColor.appColor(.neutral400)
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.numberOfLines = 0
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
        infoLabel.text = text
    }
    
    func setText(_ text: String) {
        detailLabel.text = text
    }
}

// MARK: UI Settings

extension HouseInfoView {
    private func setUpLayOuts() {
        [infoLabel, detailLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(self.snp.height)
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoLabel.snp.trailing).offset(10)
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-5)
            make.height.equalTo(self.snp.height)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
