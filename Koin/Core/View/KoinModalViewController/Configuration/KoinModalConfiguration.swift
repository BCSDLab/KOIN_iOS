//
//  KoinModalConfiguration.swift
//  koin
//
//  Created by 홍기정 on 8/15/26.
//

import UIKit

struct KoinModalConfiguration {
    let appearance: Appearance
    let content: Content
    let button: Button
    let layout: Layout
    
    init(
        appearance: Appearance,
        content: Content,
        button: Button,
        layout: Layout = .init()
    ) {
        self.appearance = appearance
        self.content = content
        self.button = button
        self.layout = layout
    }
    
    enum Appearance {
        case primary
        case new
        case destructive
    }
    
    enum Content {
        case titles(
            mainTitleText: String,
            mainTitleStyle: KoinModalStyle.TitleStyle? = nil,
            subTitleText: String,
            subTitleStyle : KoinModalStyle.TitleStyle? = nil
        )
        case singleTitle(
            text: String,
            style: KoinModalStyle.TitleStyle? = nil
        )
        case attributedTitles(
            mainTitle: NSAttributedString,
            subTitle: NSAttributedString
        )
        case attributedSingleTitle(
            title: NSAttributedString
        )
        case custom(
            customView: UIView
        )
    }
    
    enum Button {
        case buttons(
            leftButtonTitle: String,
            leftButtonAction: (()->Void)? = nil,
            leftButtonStyle: KoinModalStyle.ButtonStyle? = nil,
            rightButtonTitle: String,
            rightButtonAction: ()->Void,
            rightButtonStyle: KoinModalStyle.ButtonStyle? = nil
        )
        case singleButton(
            title: String,
            action: (()->Void)?,
            style: KoinModalStyle.ButtonStyle?
        )
        case none
    }
    
    struct Layout {
        let width: CGFloat
        let contentTopPadding: CGFloat
        let contentHorizontalPadding: CGFloat
        let contentBottomPadding: CGFloat
        let paddingBetweenContentAndButton: CGFloat
        let buttonHorizontalPadding: CGFloat
        let buttonBottomPadding: CGFloat
        
        init(
            width: CGFloat = 301,
            contentTopPadding: CGFloat = 24,
            contentHorizontalPadding: CGFloat = 32,
            contentBottomPadding: CGFloat = 0,
            paddingBetweenContentAndButton: CGFloat = 24,
            buttonHorizontalPadding: CGFloat = 32,
            buttonBottomPadding: CGFloat = 24
        ) {
            self.width = width
            self.contentTopPadding = contentTopPadding
            self.contentHorizontalPadding = contentHorizontalPadding
            self.contentBottomPadding = contentBottomPadding
            self.paddingBetweenContentAndButton = paddingBetweenContentAndButton
            self.buttonHorizontalPadding = buttonHorizontalPadding
            self.buttonBottomPadding = buttonBottomPadding
        }
    }
}

extension KoinModalConfiguration {
    var style: KoinModalStyle {
        switch appearance {
        case .primary:
            KoinModalStyle(
                mainTitle: .init(
                    textColor: .neutral700,
                    font: .pretendardMedium,
                    fontSize: 18
                ),
                subTitle: .init(
                    textColor: .neutral500,
                    font: .pretendardRegular,
                    fontSize: 14
                ),
                singleTitle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 14
                ),
                leftButton: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15,
                    borderColor: .neutral500,
                    borderWidth: 1,
                    cornerRadius: 8
                ),
                rightButton: .init(
                    textColor: .neutral0,
                    font: .pretendardMedium,
                    fontSize: 15,
                    backgroundColor: .primary500,
                    cornerRadius: 8
                )
            )
        case .new:
            KoinModalStyle(
                mainTitle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 18),
                subTitle: .init(
                    textColor: .neutral500,
                    font: .pretendardRegular,
                    fontSize: 14
                ),
                singleTitle: .init(
                    textColor: .neutral600,
                    font: .pretendardRegular,
                    fontSize: 15
                ),
                leftButton: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15,
                    borderColor: .neutral400,
                    borderWidth: 1,
                    cornerRadius: 6
                ),
                rightButton: .init(
                    textColor: .neutral0,
                    font: .pretendardMedium,
                    fontSize: 15,
                    backgroundColor: .new500,
                    cornerRadius: 6
                )
            )
        case .destructive:
            KoinModalStyle(
                mainTitle: .init(
                    textColor: .neutral700,
                    font: .pretendardMedium,
                    fontSize: 18
                ),
                subTitle: .init(
                    textColor: .neutral500,
                    font: .pretendardRegular,
                    fontSize: 14
                ),
                singleTitle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 14
                ),
                leftButton: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15,
                    borderColor: .neutral500,
                    borderWidth: 1,
                    cornerRadius: 4
                ),
                rightButton: .init(
                    textColor: .neutral0,
                    font: .pretendardMedium,
                    fontSize: 15,
                    backgroundColor: .danger700,
                    cornerRadius: 4
                )
            )
        }
    }
}


