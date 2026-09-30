//
//  ModalContentView.swift
//  koin
//
//  Created by 홍기정 on 8/15/26.
//

import UIKit
import SnapKit
import Then

final class ModalContentView: UIView {
    private static let paddingBetweenTitles: CGFloat = 8
    
    // MARK: - Porperties
    private let configuration: KoinModalConfiguration
    
    // MARK: - UI Components
    private let mainTitleLabel = UILabel()
    private let subTitleLabel = UILabel()
    
    private let singleTitleLabel = UILabel()
    
    private var customView: UIView?
    
    // MARK: - Initializer
    init(configuration: KoinModalConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ModalContentView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        switch configuration.content {
        case .titles(let mainTitleText, let mainTitleStyle, let subTitleText, let subTitleStyle):
            let mainTitleStyle = mainTitleStyle ?? configuration.style.mainTitle
            let subTitleStyle = subTitleStyle ?? configuration.style.subTitle
            apply(text: mainTitleText, style: mainTitleStyle, to: mainTitleLabel)
            apply(text: subTitleText, style: subTitleStyle, to: subTitleLabel)
        case .singleTitle(let text, let style):
            let style = style ?? configuration.style.singleTitle
            apply(text: text, style: style, to: singleTitleLabel)
        case .attributedTitles(let mainTitle, let subTitle):
            apply(title: mainTitle, to: mainTitleLabel)
            apply(title: subTitle, to: subTitleLabel)
        case .attributedSingleTitle(let title):
            apply(title: title, to: singleTitleLabel)
        case .custom(let customView):
            self.customView = customView
        }
    }
    
    private func setUpLayouts() {
        switch configuration.content {
        case .titles, .attributedTitles:
            [mainTitleLabel, subTitleLabel].forEach {
                addSubview($0)
            }
        case .singleTitle, .attributedSingleTitle:
            [singleTitleLabel].forEach {
                addSubview($0)
            }
        case .custom(let customView):
            [customView].forEach {
                addSubview($0)
            }
        }
    }
    
    private func setUpConstraints() {
        switch configuration.content {
        case .titles, .attributedTitles:
            let mainTitleLabelTopOffset: CGFloat = mainTitleLabel.font.pointSize * 0.4
            mainTitleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-mainTitleLabelTopOffset)
                $0.leading.greaterThanOrEqualToSuperview()
                $0.trailing.lessThanOrEqualToSuperview()
                $0.centerX.equalToSuperview()
            }
            subTitleLabel.snp.makeConstraints {
                $0.top.equalTo(mainTitleLabel.snp.bottom).offset(Self.paddingBetweenTitles)
                $0.leading.greaterThanOrEqualToSuperview()
                $0.trailing.lessThanOrEqualToSuperview()
                $0.bottom.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        case .singleTitle, .attributedSingleTitle:
            let singleTitleLabelTopOffset: CGFloat = singleTitleLabel.font.pointSize * 0.4
            singleTitleLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().offset(-singleTitleLabelTopOffset)
                $0.leading.greaterThanOrEqualToSuperview()
                $0.trailing.lessThanOrEqualToSuperview()
                $0.centerX.equalToSuperview()
            }
        case .custom:
            customView?.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}

extension ModalContentView {
    private func apply(
        text: String,
        style: KoinModalStyle.TitleStyle,
        to label: UILabel
    ) {
        label.do {
            $0.font = .appFont(style.font, size: style.fontSize)
            $0.textColor = .appColor(style.textColor)
            $0.setLineHeight(lineHeight: 1.6, text: text)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
    private func apply(
        title attributedString: NSAttributedString,
        to label: UILabel
    ) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let paragraphStyle = NSMutableParagraphStyle().then {
            $0.lineHeightMultiple = 1.6
            $0.alignment = .center
        }
        let fullRange = {
            let text = attributedString.string
            return (text as NSString).range(of: text)
        }()
        mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        label.attributedText = mutableAttributedString
        label.numberOfLines = 0
    }
}
