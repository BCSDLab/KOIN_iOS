//
//  LostItemListEmptyView.swift
//  Koin
//

import UIKit
import SnapKit
import Then

final class LostItemListEmptyView: UIView {
    private let symbolImageView = UIImageView(image: .appImage(asset: .sleepBcsdSymbol)).then {
        $0.contentMode = .scaleAspectFit
    }
    private let messageLabel = UILabel().then {
        $0.text = "조건에 맞는 게시글이 없어요."
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 12
    }

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        [symbolImageView, messageLabel].forEach(stackView.addArrangedSubview)
        addSubview(stackView)
        symbolImageView.snp.makeConstraints {
            $0.width.equalTo(98)
            $0.height.equalTo(75)
        }
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
