//
//  CallVanChatDateHeaderView.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import SnapKit
import Then

final class CallVanChatDateHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let dateView = UIView()
    private let dateLabel = UILabel()
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(date: String) {
        dateLabel.text = date
    }
}

extension CallVanChatDateHeaderView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        dateView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 27 / 2
        }
        dateLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.appColor(.new600)
        }
    }
    
    private func setUpLayouts() {
        [dateView, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dateView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        dateLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.bottom.equalTo(dateView).inset(4)
            $0.leading.trailing.equalTo(dateView).inset(12)
        }
    }
}
