//
//  OrderCartResetCartPopUpView.swift
//  koin
//
//  Created by 홍기정 on 10/2/25.
//

import UIKit
import Combine
import SnapKit

final class OrderCartResetCartPopUpView: UIView {
    
    // MARK: - Properties
    let rightButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let dimView = UIView().then {
        $0.backgroundColor = .appColor(.neutral800)
        $0.layer.opacity = 0.7
    }
    private let popUpView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.cornerRadius = 8
    }
    private let subTitleLabel = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardRegular, size: 15)
        $0.numberOfLines = 0
        $0.setLineHeight(lineHeight: 1.60, text: "정말로 담았던 메뉴들을\n전체 삭제하시겠어요?")
        $0.textAlignment = .center
        $0.lineBreakStrategy = .hangulWordPriority
        
    }
    private let leftButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 6
        $0.setAttributedTitle(NSAttributedString(
            string: "아니오",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral600)
            ]), for: .normal)
    }
    private let rightButton = UIButton().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 6
        $0.setAttributedTitle(NSAttributedString(
            string: "예",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral0)
            ]), for: .normal)
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
}

extension OrderCartResetCartPopUpView {

    private func setUpLayouts() {
        [dimView, popUpView, subTitleLabel, leftButton, rightButton].forEach {
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
        subTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(popUpView).inset(32)
            $0.top.equalTo(popUpView.snp.top).offset(24)
        }
        leftButton.snp.makeConstraints {
            $0.leading.equalTo(subTitleLabel)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            $0.width.equalTo((UIScreen.main.bounds.width-160) / 2)
            $0.height.equalTo(48)
        }
        rightButton.snp.makeConstraints {
            $0.top.equalTo(leftButton)
            $0.trailing.equalTo(subTitleLabel)
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

extension OrderCartResetCartPopUpView {
 
    @objc private func leftButtonTapped() {
        removeFromSuperview()
    }
    @objc private func rightButtonTapped() {
        rightButtonTappedPublisher.send()
        removeFromSuperview()
    }
}
