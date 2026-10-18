//
//  DiningNotiBottomSheetContentView.swift
//  koin
//
//  Created by 홍기정 on 10/19/26.
//

import UIKit
import SnapKit
import Then

final class DiningNotiBottomSheetContentView: UIView {
    
    // MARK: - Properties
    weak var delegate: BottomSheetViewControllerBDelegate?
    private let onSoldOutSwitchToggled: (Bool)->Void
    private let onImageUploadSwitchToggled: (Bool)->Void
    private let onNotiButtonTapped: ()->Void

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let separatorView = UIView()
    
    private let soldOutView = UIView()
    private let soldOutLabel = UILabel()
    private let soldOutSwitch = UISwitch()
    
    private let imageUploadView = UIView()
    private let imageUploadLabel = UILabel()
    private let imageUploadSwitch = UISwitch()
    
    private let notiButton = UIButton()
    private let closeButton = UIButton()

    // MARK: - Initializer
    init(
        onSoldOutSwitchToggled: @escaping (Bool)->Void,
        onImageUploadSwitchToggled: @escaping (Bool)->Void,
        onNotiButtonTapped: @escaping ()->Void,
        initialValue: DiningNoti
    ) {
        self.onSoldOutSwitchToggled = onSoldOutSwitchToggled
        self.onImageUploadSwitchToggled = onImageUploadSwitchToggled
        self.onNotiButtonTapped = onNotiButtonTapped
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        soldOutSwitch.isOn = initialValue.isDiningSoldOutPermit
        imageUploadSwitch.isOn = initialValue.isDiningImageUploadPermit
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiningNotiBottomSheetContentView {
    // MARK: - SetAddTargets
    private func setAddTargets() {
        soldOutSwitch.addTarget(
            self,
            action: #selector(didTapSoldOutSwitch(_:)),
            for: .valueChanged
        )
        imageUploadSwitch.addTarget(
            self,
            action: #selector(didTapImageUploadSwitch(_:)),
            for: .valueChanged
        )
        notiButton.addTarget(
            self,
            action: #selector(didTapNotiButton),
            for: .touchUpInside
        )
        closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
    }
    
    @objc private func didTapSoldOutSwitch(_ sender: UISwitch) {
        onSoldOutSwitchToggled(sender.isOn)
    }
    
    @objc private func didTapImageUploadSwitch(_ sender: UISwitch) {
        onImageUploadSwitchToggled(sender.isOn)
    }
    
    @objc private func didTapNotiButton() {
        onNotiButtonTapped()
        delegate?.dismiss()
    }
    
    @objc private func didTapCloseButton() {
        delegate?.dismiss()
    }
}

extension DiningNotiBottomSheetContentView {
    // MARK: - Configure
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        titleLabel.do {
            $0.setLineHeight(lineHeight: 1.6, text: "알림 설정을 허용하고\n식단 품절 알림을 받아보세요!")
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.neutral800)
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }
        
        separatorView.do {
            $0.backgroundColor = .appColor(.neutral300)
        }

        [soldOutLabel, imageUploadLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 16)
            $0.textColor = .appColor(.neutral800)
        }
        soldOutLabel.text = "식단 품절 알림 받기"
        imageUploadLabel.text = "식단 사진 업로드 알림 받기"
        
        [soldOutSwitch, imageUploadSwitch].forEach {
            $0.onTintColor = .appColor(.new500)
        }

        notiButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "알림 설정 바로가기",
                attributes: AttributeContainer([
                    .font : UIFont.appFont(.pretendardMedium, size: 15),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ])
            )
            configuration.background.backgroundColor = .appColor(.new500)
            configuration.background.cornerRadius = 4
            $0.configuration = configuration
        }
        closeButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "닫기",
                attributes: AttributeContainer([
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : UIColor.appColor(.neutral500)
                ])
            )
            configuration.background.backgroundColor = .clear
            $0.configuration = configuration
        }
    }

    private func setUpLayouts() {
        [soldOutLabel, soldOutSwitch].forEach {
            soldOutView.addSubview($0)
        }
        [imageUploadLabel, imageUploadSwitch].forEach {
            imageUploadView.addSubview($0)
        }
        [titleLabel, separatorView, soldOutView, imageUploadView, notiButton, closeButton].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        [(soldOutLabel, soldOutSwitch), (imageUploadLabel, imageUploadSwitch)].forEach { label, toggle in
            label.snp.makeConstraints {
                $0.height.equalTo(26)
                $0.top.leading.bottom.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(toggle.snp.leading).offset(-24)
            }
            toggle.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
        }
        [soldOutView, imageUploadView].forEach { wrapperView in
            wrapperView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(32)
            }
        }
        soldOutView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
        }
        imageUploadView.snp.makeConstraints {
            $0.top.equalTo(soldOutView.snp.bottom).offset(12)
        }
        
        [notiButton, closeButton].forEach { button in
            button.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(32)
            }
        }

        notiButton.snp.makeConstraints {
            $0.top.equalTo(imageUploadView.snp.bottom).offset(32)
            $0.height.equalTo(48)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(notiButton.snp.bottom).offset(16)
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
