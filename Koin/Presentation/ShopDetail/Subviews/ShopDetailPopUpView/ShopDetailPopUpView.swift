//
//  ShopDetailPopupView.swift
//  koin
//
//  Created by 홍기정 on 9/12/25.
//

import UIKit
import Combine
import SnapKit

final class ShopDetailPopUpView: UIView {
    
    // MARK: - Properties
    let leftButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let rightButtonTappedPublisher = PassthroughSubject<Int, Never>()
    
    var menuId: Int? = nil
    
    // MARK: - Components
    private let dimView = UIView().then {
        $0.backgroundColor = .appColor(.neutral800)
        $0.layer.opacity = 0.7
    }
    private let popUpView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.cornerRadius = 8
    }
    private let label = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardRegular, size: 15)
        $0.numberOfLines = 0
    }
    private let leftButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 6
    }
    
    private let rightButton = UIButton().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 6
    }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: String, leftButtonText: String, rightButtonText: String) {
        label.setLineHeight(lineHeight: 1.60, text: message)
        label.textAlignment = .center
        label.lineBreakStrategy = .hangulWordPriority
        leftButton.setAttributedTitle(NSAttributedString(
            string: leftButtonText,
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral600)
            ]), for: .normal)
        rightButton.setAttributedTitle(NSAttributedString(
            string: rightButtonText,
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral0)
            ]), for: .normal)
    }
    func configure(menuId: Int) {
        self.menuId = menuId
    }
}

extension ShopDetailPopUpView {

    private func setUpLayouts() {
        [dimView, popUpView, label, leftButton, rightButton].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        popUpView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(44)
        }
        label.snp.makeConstraints {
            $0.leading.trailing.equalTo(popUpView).inset(32)
            $0.top.equalTo(popUpView.snp.top).offset(24)
        }
        leftButton.snp.makeConstraints {
            $0.leading.equalTo(label)
            $0.top.equalTo(label.snp.bottom).offset(24)
            $0.width.equalTo((UIScreen.main.bounds.width-160) / 2)
            $0.height.equalTo(48)
        }
        rightButton.snp.makeConstraints {
            $0.top.equalTo(leftButton)
            $0.trailing.equalTo(label)
            $0.bottom.equalTo(popUpView).offset(-24)
            $0.width.equalTo(leftButton)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

extension ShopDetailPopUpView {
 
    @objc private func leftButtonTapped() {
        leftButtonTappedPublisher.send()
    }
    @objc private func rightButtonTapped() {
        guard let menuId else {
            return
        }
        rightButtonTappedPublisher.send(menuId)
    }
}
