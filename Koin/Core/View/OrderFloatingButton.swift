//
//  OrderFloatingButton.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import UIKit
import Lottie
import Then
import SnapKit

final class OrderFloatingButton: UIControl {
        
    // MARK: - Properties
    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subtitleText: String? {
        get { subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    
    var rightImage: UIImage? {
        get { rightImageView.image }
        set { rightImageView.image = newValue }
    }
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.2
    }
    
    let lottieView = LottieAnimationView().then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fillEqually
        $0.spacing = 0
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.new500)
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let rightImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.appImage(asset: .chevronRight)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.appColor(.new500)
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        setAddTarget()
    }
    
    private func setAddTarget() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Lottie Animation Methods
    func setLottieAnimation(named name: String, bundle: Bundle = .main) {
        lottieView.animation = LottieAnimation.named(name, bundle: bundle)
    }
    
    func playLottieAnimation() {
        lottieView.play()
    }
    
    func stopLottieAnimation() {
        lottieView.stop()
    }
}

// MARK: - @objc
extension OrderFloatingButton {
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.containerView.alpha = 0.8
        }
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1.0
        }
    }
}

// MARK: - UI Function
extension OrderFloatingButton {
    private func setUpLayout() {
        addSubview(containerView)
        
        containerView.addSubview(lottieView)
        containerView.addSubview(labelStackView)
        containerView.addSubview(rightImageView)
        
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        lottieView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(57)
        }
        
        labelStackView.snp.makeConstraints {
            $0.leading.equalTo(lottieView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-12)
        }
        
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14.5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(24)
            $0.height.equalTo(12)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}

extension OrderFloatingButton {
    var lottieAnimationView: LottieAnimationView {
        return lottieView
    }
}
