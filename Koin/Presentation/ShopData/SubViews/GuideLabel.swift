//
//  GuideLabel.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import UIKit

final class GuideLabel: UIView {
    
    let copyButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let leftLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
    }
    
    let rightLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
    }
    
    private let copyButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
        $0.setImage(UIImage.appImage(asset: .copy), for: .normal)
        $0.isHidden = true
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        leftLabel.text = text
    }
    
    @objc private func copyText() {
        UIPasteboard.general.string = rightLabel.text
        copyButtonPublisher.send(())
    }
    
    func configure(text: String) {
        rightLabel.text = text
    }
}

// MARK: UI Settings

extension GuideLabel {
    private func setUpLayOuts() {
        [leftLabel, rightLabel, copyButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        leftLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading)
            make.top.equalTo(self.snp.top)
        }
        rightLabel.snp.makeConstraints { make in
            make.leading.equalTo(leftLabel.snp.trailing).offset(8.19)
            make.top.equalTo(self.snp.top)
            make.trailing.lessThanOrEqualTo(self.snp.trailing).offset(-8.19)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        copyButton.snp.makeConstraints { make in
            make.leading.equalTo(rightLabel.snp.trailing).offset(5)
            make.top.equalTo(self.snp.top)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
    
    func showCopyButton() {
        copyButton.isHidden = false
    }
}

