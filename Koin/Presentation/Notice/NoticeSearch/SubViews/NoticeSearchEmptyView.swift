//
//  NoticeSearchEmptyView.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import UIKit

final class NoticeSearchEmptyView: UIView {
    
    // MARK: - UI Components
    private let layoutGuide = UILayoutGuide()
    
    private let sleepySymbolImageView = UIImageView(image: .appImage(asset: .sleepBcsdSymbol)).then {
        $0.contentMode = .scaleAspectFit
    }
    private let emptyLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle().then {
            $0.alignment = .center
            $0.lineSpacing = 14 * 0.6
        }
        $0.attributedText = NSAttributedString(
            string: "일치하는 공지글이 없습니다.\n다른 키워드로 다시 시도해주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral500),
                .paragraphStyle: paragraphStyle
            ]
        )
        $0.numberOfLines = 2
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoticeSearchEmptyView {
    private func configureView() {
        [sleepySymbolImageView, emptyLabel].forEach {
            addSubview($0)
        }
        [layoutGuide].forEach {
            addLayoutGuide($0)
        }
        
        sleepySymbolImageView.snp.makeConstraints {
            $0.top.centerX.equalTo(layoutGuide)
            $0.width.equalTo(98)
        }
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(sleepySymbolImageView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalTo(layoutGuide)
        }
        
        layoutGuide.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.lessThanOrEqualToSuperview()
        }
    }
}
