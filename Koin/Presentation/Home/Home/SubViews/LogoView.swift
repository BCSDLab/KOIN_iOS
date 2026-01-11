//
//  LogoView.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//
import Combine
import UIKit

final class LogoView: UIView {
    
    let lineButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .logo)
    }
    
    let lineButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .line3), for: .normal)
        $0.tintColor = UIColor.appColor(.neutral0)
        $0.imageView?.contentMode = .scaleAspectFill
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        lineButton.addTarget(self, action: #selector(lineButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension LogoView {
    @objc func lineButtonTapped() {
        lineButtonPublisher.send()
    }
}
// MARK: UI Settings

extension LogoView {
    private func setUpLayOuts() {
        [logoImageView, lineButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(58)
            make.height.equalTo(32)
            make.top.equalTo(self.snp.top).offset(64)
            make.leading.equalTo(self.snp.leading).offset(20)
        }
        lineButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(74)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.width.equalTo(24)
            make.height.equalTo(18)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpRoundedCorners()
        setUpShadow()
        self.backgroundColor = UIColor.appColor(.primary500)
    }
    
    private func setUpRoundedCorners() {
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.clipsToBounds = true
    }
    
    private func setUpShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
    }
}

