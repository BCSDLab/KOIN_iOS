//
//  ShopInfoFooterView.swift
//  koin
//
//  Created by 홍기정 on 1/10/26.
//

import UIKit

final class ShopInfoFooterView: UICollectionReusableView {
    
    // MARK: - Static
    static let identifier = "ShopInfoFooterView"
    
    // MARK: - UI Components
    private let emptyResultLabel = UILabel().then {
        let firstLine = "이용 가능한 가게가 없어요"
        let secondLine = "조건을 변경하고 다시 검색해주세요"
        let text = "\(firstLine)\n\(secondLine)"

        let attributedText = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center

        attributedText.addAttribute(.font, value: UIFont.appFont(.pretendardBold, size: 18), range: NSRange(location: 0, length: firstLine.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.appColor(.new500), range: NSRange(location: 0, length: firstLine.count))

        let secondLineRange = NSRange(location: firstLine.count + 1, length: secondLine.count)
        attributedText.addAttribute(.font, value: UIFont.appFont(.pretendardMedium, size: 14), range: secondLineRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral600), range: secondLineRange)

        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))

        $0.attributedText = attributedText
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let emptyResultImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .orderEmptyLogo)
    }

    private lazy var emptyResultStackView = UIStackView(arrangedSubviews: [emptyResultImageView,emptyResultLabel]).then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.backgroundColor = UIColor.appColor(.newBackground)
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateEmptyResultView(isEmpty: Bool) {
        emptyResultStackView.isHidden = !isEmpty
    }
}

extension ShopInfoFooterView {
    
    private func configureView() {
        [emptyResultStackView].forEach {
            addSubview($0)
        }
        emptyResultStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
    }
}
