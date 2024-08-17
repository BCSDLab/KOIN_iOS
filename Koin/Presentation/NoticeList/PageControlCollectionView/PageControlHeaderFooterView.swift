//
//  PageControlHeaderFooterView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Then
import UIKit

final class PageControlHeaderFooterView: UICollectionReusableView {
    static let identifier = "PageControlHeaderFooterView"
    var pageControlReloadPublisher = PassthroughSubject<(), Never>()
    
    private let pageControlBtn = UIButton().then {
        $0.backgroundColor = .clear  // 버튼 배경 설정
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pageControlBtn)
        setupViews()
        pageControlBtn.addTarget(self, action: #selector(tapPageControlBtn), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        pageControlBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func updateButton(text: String) {
        pageControlBtn.setTitle(text, for: .normal)
        pageControlBtn.setTitleColor(.appColor(.neutral600), for: .normal)
        pageControlBtn.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
    }
    
    @objc func tapPageControlBtn() {
        pageControlReloadPublisher.send()
    }
}
