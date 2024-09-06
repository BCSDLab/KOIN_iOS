//
//  PolicyListTableViewCell.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import UIKit

final class PolicyListTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
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
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
              titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
              titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
              titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
              titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
          ])
      }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
