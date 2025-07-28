//
//  OrderLoginPopupView.swift
//  koin
//
//  Created by 이은지 on 7/28/25.
//

import UIKit
import SnapKit

final class OrderLoginPopupView: UIView {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
    }
    
    private let loginInfoTitleLabel = UILabel().then {
        $0.text = "코인 주문을 이용하기 위해선\n로그인이 필요해요."
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let loginInfoSubtitleLabel = UILabel().then {
        $0.text = "로그인 후 코인의 주문 기능을\n이용해보세요!"
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
    }
    
    private let goToLoginButton = UIButton().then {
        $0.setTitle("로그인하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Init
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
    
    // MARK: - Set Add Target
    private func setAddTarget(){
    }
}

// MARK: - @objc
extension OrderLoginPopupView {
    
//    @objc private func confirmButtonTapped() {
//
//        hide()
//    }
//    
//    @objc private func cancelButtonTapped() {
//        hide()
//    }
}

// MARK: - Configure View
extension OrderLoginPopupView {
    private func setUpLayOuts() {
        [backgroundView, containerView].forEach {
            addSubview($0)
        }

        [loginInfoTitleLabel, loginInfoSubtitleLabel, closeButton, goToLoginButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(44)
            $0.height.greaterThanOrEqualTo(300)
        }
        
        loginInfoSubtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        loginInfoTitleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loginInfoSubtitleLabel.snp.top).offset(8)
            $0.height.equalTo(58)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(loginInfoSubtitleLabel.snp.bottom).offset(24)
            $0.leading.equalTo(loginInfoTitleLabel.snp.leading)
            $0.trailing.equalTo(self.snp.centerX).offset(-4)
            $0.height.equalTo(48)
        }
        
        goToLoginButton.snp.makeConstraints {
            $0.top.equalTo(loginInfoSubtitleLabel.snp.bottom).offset(24)
            $0.leading.equalTo(self.snp.centerX).offset(4)
            $0.trailing.equalTo(loginInfoTitleLabel.snp.trailing)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
