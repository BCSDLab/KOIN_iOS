//
//  LandSearchEmptyView.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import UIKit
import SnapKit

final class LandSearchEmptyView: UIView {

    // MARK: - UI Components
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let messageLabel = UILabel()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandSearchEmptyView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.alignment = .center
        }
        imageView.do {
            $0.image = .appImage(asset: .sleepBcsdSymbol)
            $0.contentMode = .scaleAspectFit
        }
        messageLabel.do {
            $0.text = "검색결과가 없습니다.\n다른 검색어로 다시 검색해주세요."
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral500)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }

    private func setUpLayouts() {
        addSubview(stackView)
        [imageView, messageLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.width.equalTo(98)
            $0.height.equalTo(75)
        }
        messageLabel.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }
}
