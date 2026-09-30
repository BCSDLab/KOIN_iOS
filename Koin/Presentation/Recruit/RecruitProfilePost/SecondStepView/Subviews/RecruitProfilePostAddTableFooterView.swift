//
//  RecruitProfilePostAddTableFooterView.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostAddTableFooterView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    let addButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let addButton = UIButton(type: .system)
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(title: String) {
        addButton.setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.new500)
            ]
        ), for: .normal)
    }

    // MARK: - Objc
    @objc private func addButtonTapped() {
        addButtonTappedPublisher.send()
    }
}

extension RecruitProfilePostAddTableFooterView {
    private func configureView() {
        contentView.backgroundColor = .appColor(.newBackground)
        addButton.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        }
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
