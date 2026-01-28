//
//  ChatDateHeaderView.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import UIKit

final class ChatDateHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    
    private let dateLabel = UILabel().then {
        $0.layer.cornerRadius = 27.0/2
        $0.layer.masksToBounds = true
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.backgroundColor = UIColor.appColor(.neutral200)
        $0.textColor = UIColor.appColor(.primary600)
        $0.textAlignment = .center
    }
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
}

extension ChatDateHeaderView {
    func configure(date: ChatDateInfo) {
        dateLabel.text = "\(date.year)년 \(date.month)월 \(date.day)일"
    }
}

extension ChatDateHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(dateLabel)
    }
    
    private func setUpConstraints() {
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(27)
            $0.width.equalTo(112)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
