//
//  PolicyListTableViewCell.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import UIKit

final class PolicyListTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let titleLabel = InsetLabel(top: 0, left: 48, bottom: 0, right: 0).then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(titleText: String) {
        titleLabel.text = titleText
    }
}

extension PolicyListTableViewCell {
    private func setUpLayouts() {
        [titleLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading)
        }
      }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
