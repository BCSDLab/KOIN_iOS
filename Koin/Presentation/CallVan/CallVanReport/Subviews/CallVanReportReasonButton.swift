//
//  CallVanReportReasonButton.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import SnapKit
import Then

final class CallVanReportReasonButton: UIButton {
    
    let title: String
    
    override var isSelected: Bool {
        didSet {
            radioButtonImageView.image = isSelected ? UIImage.appImage(asset: .callVanRadioButtonSelected) : UIImage.appImage(asset: .callVanRadioButtonDeselected)
        }
    }
    
    // MARK: - UI Components
    private let radioButtonImageView = UIImageView()
    private let reasonLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Initializer
    init(title: String, description: String?) {
        self.title = title
        super.init(frame: .zero)
        configureView()
        reasonLabel.text = title
        descriptionLabel.text = description
        isSelected = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CallVanReportReasonButton {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        radioButtonImageView.do {
            $0.image = UIImage.appImage(asset: .callVanRadioButtonDeselected)
            $0.contentMode = .scaleAspectFit
        }
        reasonLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        descriptionLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral500)
        }
    }
    
    private func setUpLayouts() {
        [radioButtonImageView, reasonLabel, descriptionLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        radioButtonImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        reasonLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalToSuperview()
            $0.leading.equalTo(radioButtonImageView.snp.trailing).offset(16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(reasonLabel.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.equalTo(reasonLabel)
        }
    }
}
