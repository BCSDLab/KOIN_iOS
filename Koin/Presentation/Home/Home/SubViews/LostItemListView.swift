//
//  LostItemListView.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import Combine

final class LostItemListView: UIView {
    
    // MARK: - Properties
    let lostItemListTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let nameLabel = UILabel().then {
        $0.text = "분실물"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
    }
    
    private let chevronButton = UIButton().then {
        $0.setImage(UIImage(named: "chevronRightBlue")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = UIColor(hexCode: "1C1B1F")
    }
    
    private let descriptionButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral100)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(lostItemStats: LostItemStats) {
        let title: String
        if 50 <= lostItemStats.foundCount {
            title = "지금까지 \(lostItemStats.foundCount)명이 분실물을 찾았어요."
        } else {
            title = "\(lostItemStats.notFoundCount)개의 분실물이 주인을 찾고있어요."
        }
        descriptionButton.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 14),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]), for: .normal)
    }
}

extension LostItemListView {
    
    private func setAddTargets() {
        [chevronButton, descriptionButton].forEach {
            $0.addTarget(self, action: #selector(lostItemListTapped), for: .touchUpInside)
        }
    }
    @objc private func lostItemListTapped() {
        lostItemListTappedPublisher.send()
    }
}
extension LostItemListView {
    
    private func setLayouts() {
        [nameLabel, chevronButton, descriptionButton].forEach {
            addSubview($0)
        }
    }
    private func setConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        chevronButton.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(29)
        }
        descriptionButton.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
    }
    private func configureView() {
        setLayouts()
        setConstraints()
    }
}
