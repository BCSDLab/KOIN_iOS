//
//  BusRouteTagLabel.swift
//  koin
//
//  Created by 홍기정 on 11/4/26.
//

import UIKit

/// 노선/버스 종류 파스텔 캡슐 태그 (padding 8 h / 1 v, Medium 10)
final class BusRouteTagLabel: UILabel {
    private let horizontalPadding: CGFloat = 8
    private let verticalPadding: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .appFont(.pretendardMedium, size: 10)
        textAlignment = .center
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + horizontalPadding * 2, height: size.height + verticalPadding * 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    func configure(shuttleRouteType: ShuttleRouteType) {
        switch shuttleRouteType {
        case .circular:
            configure(text: shuttleRouteType.rawValue, background: .success200, foreground: .success700)
        case .weekday:
            configure(text: shuttleRouteType.rawValue, background: .warning100, foreground: .warning600)
        default:
            configure(text: shuttleRouteType.rawValue, background: .info200, foreground: .info700)
        }
    }

    func configure(text: String, background: ColorAsset, foreground: ColorAsset) {
        self.text = text
        backgroundColor = .appColor(background)
        textColor = .appColor(foreground)
        invalidateIntrinsicContentSize()
    }
}
