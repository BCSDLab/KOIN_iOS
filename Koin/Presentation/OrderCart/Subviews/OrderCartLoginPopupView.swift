//
//  OrderCartLoginPopUpView.swift
//  koin
//
//  Created by 홍기정 on 10/27/25.
//

import UIKit
import Combine
import SnapKit

final class OrderCartLoginPopUpView: UIView {
    
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
    private let titleLabel = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardMedium, size: 18)
        $0.numberOfLines = 2
        $0.setLineHeight(lineHeight: 1.60, text: "코인 주문을 이용하기 위해선\n로그인이 필요해요")
        $0.textAlignment = .center
    }
    private let subTitleLabel = UILabel().then {
        $0.textColor = .appColor(.gray)
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.numberOfLines = 0
        $0.setLineHeight(lineHeight: 1.60, text: "로그인 후 코인의 주문 기능을\n이용해보세요!")
        $0.textAlignment = .center
    }
    private let leftButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 6
        $0.setAttributedTitle(NSAttributedString(
            string: "닫기",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 15),
                .foregroundColor: UIColor.appColor(.neutral600)
            ]), for: .normal)
    }
    private let rightButton = UIButton().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 6
        $0.setAttributedTitle(NSAttributedString(
            string: "로그인하기",
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

extension OrderCartLoginPopUpView {
 
    @objc private func leftButtonTapped() {
        removeFromSuperview()
    }
    @objc private func rightButtonTapped() {
        rightButtonTappedPublisher.send()
        removeFromSuperview()
    }
}

extension OrderCartLoginPopUpView {

    private func setUpLayouts() {
        [dimView, popUpView, titleLabel, subTitleLabel, leftButton, rightButton].forEach {
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
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(popUpView).inset(32)
            $0.top.equalTo(popUpView.snp.top).offset(24)
        }
        subTitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
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
