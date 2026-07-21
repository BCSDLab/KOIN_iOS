//
//  HomeLogoView.swift
//  koin
//
//  Created by 홍기정 on 7/12/26.
//

import UIKit

final class HomeLogoView: UIView {
    
    // MARK: - UI Components
    let symbolLogoImageView = UIImageView(image: .appImage(asset: .bcsdSymbolLogo))
    let textLogoImageView = UIImageView(image: .appImage(asset: .koinTextLogo))
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeLogoView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        symbolLogoImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        textLogoImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }
    
    private func setUpLayouts() {
        [symbolLogoImageView, textLogoImageView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        symbolLogoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(46)
            $0.height.equalTo(37)
        }
        textLogoImageView.snp.makeConstraints {
            $0.leading.equalTo(symbolLogoImageView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(63)
            $0.height.equalTo(21)
        }
    }
}
