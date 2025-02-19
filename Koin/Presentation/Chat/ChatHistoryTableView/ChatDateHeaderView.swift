//
//  ChatDateHeaderView.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import UIKit

final class ChatDateHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    
    private let dateLabel = UILabel().then { _ in
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
    func configure(text: String) {
    
    }
}

extension ChatDateHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(dateLabel)
    }
    
    private func setUpConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
