//
//  ServiceSelectTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit

final class ServiceSelectTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let serviceLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(service: String) {
        serviceLabel.text = service
    }
}

extension ServiceSelectTableViewCell {
    
    private func configureView() {
        [serviceLabel, separatorView].forEach {
            contentView.addSubview($0)
        }
        serviceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        selectionStyle = .none
    }
}
