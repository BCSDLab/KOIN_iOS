//
//  DiningNotiContentViewController.swift
//  koin
//
//  Created by 김나훈 on 7/29/24.
//

import Combine
import Then
import UIKit

final class DiningNotiContentViewController: UIViewController {
    
    
    let soldOutSwitchPublisher = PassthroughSubject<Bool, Never>()
    let imageUploadSwitchPublisher = PassthroughSubject<Bool, Never>()
    let shortcutButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let diningNotiLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let text = "알림 설정을 허용하고\n식단 품절 알림을 받아보세요!"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.numberOfLines = 2
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let soldOutNotiLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.text = "식단 품절 알림 받기"
    }
    
    private let soldOutSwitch = UISwitch().then {
        $0.onTintColor = UIColor.appColor(.primary500)
        $0.transform = CGAffineTransformMakeScale(0.8, 0.8)
    }
    
    private let imageUploadNotiLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.text = "식단 사진 업로드 알림 받기"
    }
    
    private let imageUploadSwitch = UISwitch().then {
        $0.onTintColor = UIColor.appColor(.primary500)
        $0.transform = CGAffineTransformMakeScale(0.8, 0.8)
    }
    
    private let notiShortcutButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("알림 설정 바로가기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        soldOutSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        imageUploadSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        notiShortcutButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
}

extension DiningNotiContentViewController {
    
    func updateButtonIsOn(_ isOn: (Bool, Bool)) {
        soldOutSwitch.isOn = isOn.0
        imageUploadSwitch.isOn = isOn.1
    }
    
    func dissmissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case notiShortcutButton: shortcutButtonPublisher.send(())
        default: dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        switch sender {
        case soldOutSwitch: soldOutSwitchPublisher.send(sender.isOn)
        default: imageUploadSwitchPublisher.send(sender.isOn)
        }
    }
}

extension DiningNotiContentViewController {
    
    private func setUpLayOuts() {
        [diningNotiLabel, separateView, soldOutNotiLabel, soldOutSwitch, imageUploadNotiLabel, imageUploadSwitch, notiShortcutButton, cancelButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        diningNotiLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(24)
            make.leading.equalTo(view.snp.leading).offset(32)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(diningNotiLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        soldOutNotiLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(32)
        }
        soldOutSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(soldOutNotiLabel.snp.centerY)
            make.trailing.equalTo(view.snp.trailing).offset(-32)
        }
        imageUploadNotiLabel.snp.makeConstraints { make in
            make.top.equalTo(soldOutNotiLabel.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(32)
        }
        imageUploadSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(imageUploadNotiLabel.snp.centerY)
            make.trailing.equalTo(view.snp.trailing).offset(-32)
        }
        notiShortcutButton.snp.makeConstraints { make in
            make.top.equalTo(imageUploadNotiLabel.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(32)
            make.trailing.equalTo(view.snp.trailing).offset(-32)
            make.height.equalTo(48)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(notiShortcutButton.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(32)
            make.trailing.equalTo(view.snp.trailing).offset(-32)
            make.height.equalTo(22)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

