//
//  RecruitProfilePostDepartmentTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/14/26.
//

import SnapKit
import Then
import UIKit

final class RecruitProfilePostDepartmentTableViewCell: UITableViewCell {

    // MARK: - UI Component
    private let departmentLabel = UILabel()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(department: String) {
        departmentLabel.text = department
    }
}

extension RecruitProfilePostDepartmentTableViewCell {
    private func configureView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        departmentLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
        }

        contentView.addSubview(departmentLabel)
        
        departmentLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}
