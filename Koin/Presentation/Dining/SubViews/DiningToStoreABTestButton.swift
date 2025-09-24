//
//  DiningToStoreABTestButton.swift
//  koin
//
//  Created by 이은지 on 9/24/25.
//

import UIKit
import SnapKit

final class DiningToStoreABTestButton: UIControl {
    
    // MARK: - UI Components
    
    private let leftLabel = UILabel().then {
        $0.text = "오늘 학식 메뉴가 별로라면?"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let rightLabel = UILabel().then {
        $0.text = "주변상점 보기"
        $0.font = UIFont.appFont(.pretendardBold, size: 14)
        $0.textColor = .white
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.info100)
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowRadius = 8
        $0.layer.shadowOffset = .init(width: 0, height: 2)
    }
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Functions

extension DiningToStoreABTestButton {
    private func setUpLayOuts() {
        addSubview(containerView)
        
        [leftLabel, rightLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        leftLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        rightLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(30)
            $0.width.equalTo(92)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
