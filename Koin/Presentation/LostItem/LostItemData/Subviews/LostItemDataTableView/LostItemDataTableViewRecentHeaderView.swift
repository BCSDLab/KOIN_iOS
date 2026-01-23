//
//  LostItemDataTableViewRecentHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit

final class LostItemDataTableViewRecentHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "최근 게시물"
    }
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LostItemDataTableViewRecentHeaderView {
    
    private func configureView() {
        [titleLabel].forEach {
            addSubview($0)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        backgroundColor = .white
    }
}
