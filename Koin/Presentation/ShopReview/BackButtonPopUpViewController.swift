//
//  CustomAlertViewController.swift
//  koin
//
//  Created by 김성민 on 11/4/25.
//

import UIKit
import SnapKit

final class BackButtonPopUpViewController: UIViewController {
    var onStop: (() -> Void)?
    
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    private let card = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "리뷰 수정을 그만하시겠어요?"
        $0.textAlignment = .center
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.setFont(.body2)
    }
    
    private let stopButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor.appColor(.neutral600)
        config.background.backgroundColor = UIColor.appColor(.neutral0)
        config.background.strokeColor = UIColor.appColor(.neutral400)
        config.background.strokeWidth = 1
        config.attributedTitle = AttributedString(
            "그만하기",
            attributes: .init([.font: UIFont.setFont(.body2Strong)])
        )
        config.contentInsets = .init(top: 12, leading: 31.25, bottom: 12, trailing: 31.25)
        $0.configuration = config
    }
    
    private let keepButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor.appColor(.neutral0)
        config.background.backgroundColor = UIColor.appColor(.new500)
        config.attributedTitle = AttributedString(
            "계속쓰기",
            attributes: .init([.font: UIFont.setFont(.body2Strong)])
        )
        config.contentInsets = .init(top: 12, leading: 31.25, bottom: 12, trailing: 31.25)
        $0.configuration = config
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        keepButton.addTarget(self, action: #selector(keepButtonTapped), for: .touchUpInside)
    }
    
    
    private func configureView() {
        setLayouts()
        setUpConstraints()
    }
    
    private func setLayouts() {
        view.backgroundColor = .clear
        view.addSubview(dimView)
        view.addSubview(card)
        [titleLabel, stopButton, keepButton].forEach{
            card.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        card.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(144)
            $0.width.equalTo(301)
        }
        titleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
        }
        stopButton.snp.makeConstraints{
            $0.height.equalTo(48)
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        keepButton.snp.makeConstraints{
            $0.size.equalTo(stopButton)
            $0.leading.equalTo(stopButton.snp.trailing).offset(8)
            $0.centerY.equalTo(stopButton)
        }
    }
    
    
    
    @objc private func stopButtonTapped() {
        dismiss(animated: true) { [weak self] in self?.onStop?() }
    }
    
    @objc private func keepButtonTapped() {
        dismiss(animated: true)
    }
}
