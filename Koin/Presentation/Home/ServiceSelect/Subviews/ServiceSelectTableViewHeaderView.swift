//
//  ServiceSelectTableViewHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit

final class ServiceSelectTableViewHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let serviceLabel = UILabel().then {
        $0.text = "서비스"
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral700)
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

extension ServiceSelectTableViewHeaderView {
    
    private func configureView() {
        [serviceLabel].forEach {
            contentView.addSubview($0)
        }
        serviceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        contentView.backgroundColor = .appColor(.neutral50)
    }
}
