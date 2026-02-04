//
//  ServiceSelectTableHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import SnapKit
import Combine

final class ServiceSelectTableHeaderView: UIView {
    
    // MARK: - Properties
    let loginButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let labelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .firstBaseline
    }
    private let nameLabel = UILabel().then {
        $0.text = "익명"
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.primary500)
    }
    private let greetingLabel = UILabel().then {
        $0.text = "님, 안녕하세요!"
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral600)
    }
    private let loginDescriptionLabel = UILabel().then {
        $0.text = "로그인 후 더 많은 기능을 사용하세요."
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral600)
        $0.isHidden = true
    }
    
    private let loginButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(
            string: "로그인",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor: UIColor.appColor(.neutral700)
            ]),for: .normal)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTarget()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showName(name: String) {
        nameLabel.text = name
        nameLabel.isHidden = false
        greetingLabel.isHidden = false
        loginDescriptionLabel.isHidden = true
        loginButton.setAttributedTitle(NSAttributedString(
            string: "로그아웃",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor: UIColor.appColor(.neutral700)
            ]),for: .normal)
    }
    func hideName() {
        nameLabel.isHidden = true
        greetingLabel.isHidden = true
        loginDescriptionLabel.isHidden = false
        loginButton.setAttributedTitle(NSAttributedString(
            string: "로그인",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor: UIColor.appColor(.neutral700)
            ]),for: .normal)
    }
    
    // MARK: - setAddTarget
    private func setAddTarget() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    @objc private func loginButtonTapped() {
        loginButtonTappedPublisher.send()
    }
}

extension ServiceSelectTableHeaderView {
    
    private func setUpLayouts() {
        [nameLabel, greetingLabel, loginDescriptionLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
        [labelStackView, loginButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        labelStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-60)
        }
        loginButton.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-13)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
