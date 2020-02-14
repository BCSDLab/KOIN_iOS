//
//  AztecView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Aztec
import Gridicons

struct AztecView: UIViewRepresentable {
    //let htmlContent: String
    let textView: Aztec.TextView
    
    init() {
        textView = Aztec.TextView(
            defaultFont: UIFont.systemFont(ofSize: 16),
        defaultParagraphStyle: ParagraphStyle.default,
        defaultMissingImage: UIImage(imageLiteralResourceName: "board_free"))
    }
    
    init(html: String) {
        textView = Aztec.TextView(
            defaultFont: UIFont.systemFont(ofSize: 16),
        defaultParagraphStyle: ParagraphStyle.default,
        defaultMissingImage: UIImage(imageLiteralResourceName: "board_free"))
        set_html(html: html)
    }

    func makeUIView(context: Context) -> Aztec.TextView {
        textView.sizeToFit()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return textView
    }

    func updateUIView(_ uiView: Aztec.TextView, context: Context) {
        //uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func set_html(html: String) {
        textView.setHTML(html)
    }
    
    func get_html() -> String {
        return textView.getHTML()
    }
    
    func toggleBold() {
        textView.toggleBold(range: textView.selectedRange)
    }
    
    func toggleItalic() {
        textView.toggleItalic(range: textView.selectedRange)
    }
    
    func toggleUnderline() {
        textView.toggleUnderline(range: textView.selectedRange)
    }
    
    func toggleStrikethrough() {
        textView.toggleStrikethrough(range: textView.selectedRange)
    }
    func toggleBlockquote() {
        textView.toggleBlockquote(range: textView.selectedRange)
    }
    func insertHorizontalRuler() {
        textView.replaceWithHorizontalRuler(at: textView.selectedRange)
    }
    func toggleUnorderedList() {
        textView.toggleUnorderedList(range: textView.selectedRange)
    }

    func toggleOrderedList() {
        textView.toggleOrderedList(range: textView.selectedRange)
    }
    
    func toggleH1() {
        textView.toggleHeader(.h1, range: textView.selectedRange)
    }
    func toggleH2() {
        textView.toggleHeader(.h2, range: textView.selectedRange)
    }
    func toggleH3() {
        textView.toggleHeader(.h3, range: textView.selectedRange)
    }
    
    
    func headerLevelForSelectedText() -> Header.HeaderType {
        var identifiers = Set<FormattingIdentifier>()
        if (textView.selectedRange.length > 0) {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }
        let mapping: [FormattingIdentifier: Header.HeaderType] = [
            .header1 : .h1,
            .header2 : .h2,
            .header3 : .h3,
            .header4 : .h4,
            .header5 : .h5,
            .header6 : .h6,
        ]
        for (key,value) in mapping {
            if identifiers.contains(key) {
                return value
            }
        }
        return .none
    }
}

extension AztecView {
    
    static var tintedMissingImage: UIImage = {
        if #available(iOS 13.0, *) {
            return Gridicon.iconOfType(.image).withTintColor(.label)
        } else {
            // Fallback on earlier versions
            return Gridicon.iconOfType(.image)
        }
    }()
    
    struct Constants {
        static let defaultContentFont   = UIFont.systemFont(ofSize: 14)
        static let defaultHtmlFont      = UIFont.systemFont(ofSize: 24)
        //static let defaultMissingImage  = tintedMissingImage
        static let formatBarIconSize    = CGSize(width: 20.0, height: 20.0)
        static let headers              = [Header.HeaderType.none, .h1, .h2, .h3, .h4, .h5, .h6]
        static let lists                = [TextList.Style.unordered, .ordered]
        static let moreAttachmentText   = "more"
        static let titleInsets          = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        static var mediaMessageAttributes: [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                                                            .paragraphStyle: paragraphStyle,
                                                            .foregroundColor: UIColor.white]
            return attributes
        }
    }
}

extension FormattingIdentifier {

    var iconImage: UIImage {

        switch(self) {
        case .media:
            return gridicon(.addOutline)
        case .p:
            return gridicon(.heading)
        case .bold:
            return gridicon(.bold)
        case .italic:
            return gridicon(.italic)
        case .underline:
            return gridicon(.underline)
        case .strikethrough:
            return gridicon(.strikethrough)
        case .blockquote:
            return gridicon(.quote)
        case .orderedlist:
            return gridicon(.listOrdered)
        case .unorderedlist:
            return gridicon(.listUnordered)
        case .link:
            return gridicon(.link)
        case .horizontalruler:
            return gridicon(.minusSmall)
        case .sourcecode:
            return gridicon(.code)
        case .more:
            return gridicon(.readMore)
        case .header1:
            return gridicon(.headingH1)
        case .header2:
            return gridicon(.headingH2)
        case .header3:
            return gridicon(.headingH3)
        case .header4:
            return gridicon(.headingH4)
        case .header5:
            return gridicon(.headingH5)
        case .header6:
            return gridicon(.headingH6)
        case .code:
            return gridicon(.posts)
        default:
            return gridicon(.help)
        }
    }

    private func gridicon(_ gridiconType: GridiconType) -> UIImage {
        let size = AztecView.Constants.formatBarIconSize
        return Gridicon.iconOfType(gridiconType, withSize: size)
    }

    var accessibilityIdentifier: String {
        switch(self) {
        case .media:
            return "formatToolbarInsertMedia"
        case .p:
            return "formatToolbarSelectParagraphStyle"
        case .bold:
            return "formatToolbarToggleBold"
        case .italic:
            return "formatToolbarToggleItalic"
        case .underline:
            return "formatToolbarToggleUnderline"
        case .strikethrough:
            return "formatToolbarToggleStrikethrough"
        case .blockquote:
            return "formatToolbarToggleBlockquote"
        case .orderedlist:
            return "formatToolbarToggleListOrdered"
        case .unorderedlist:
            return "formatToolbarToggleListUnordered"
        case .link:
            return "formatToolbarInsertLink"
        case .horizontalruler:
            return "formatToolbarInsertHorizontalRuler"
        case .sourcecode:
            return "formatToolbarToggleHtmlView"
        case .more:
            return "formatToolbarInsertMore"
        case .header1:
            return "formatToolbarToggleH1"
        case .header2:
            return "formatToolbarToggleH2"
        case .header3:
            return "formatToolbarToggleH3"
        case .header4:
            return "formatToolbarToggleH4"
        case .header5:
            return "formatToolbarToggleH5"
        case .header6:
            return "formatToolbarToggleH6"
        case .code:
            return "formatToolbarCode"
        default:
            return ""
        }
    }

    var accessibilityLabel: String {
        switch(self) {
        case .media:
            return NSLocalizedString("Insert media", comment: "Accessibility label for insert media button on formatting toolbar.")
        case .p:
            return NSLocalizedString("Select paragraph style", comment: "Accessibility label for selecting paragraph style button on formatting toolbar.")
        case .bold:
            return NSLocalizedString("Bold", comment: "Accessibility label for bold button on formatting toolbar.")
        case .italic:
            return NSLocalizedString("Italic", comment: "Accessibility label for italic button on formatting toolbar.")
        case .underline:
            return NSLocalizedString("Underline", comment: "Accessibility label for underline button on formatting toolbar.")
        case .strikethrough:
            return NSLocalizedString("Strike Through", comment: "Accessibility label for strikethrough button on formatting toolbar.")
        case .blockquote:
            return NSLocalizedString("Block Quote", comment: "Accessibility label for block quote button on formatting toolbar.")
        case .orderedlist:
            return NSLocalizedString("Ordered List", comment: "Accessibility label for Ordered list button on formatting toolbar.")
        case .unorderedlist:
            return NSLocalizedString("Unordered List", comment: "Accessibility label for unordered list button on formatting toolbar.")
        case .link:
            return NSLocalizedString("Insert Link", comment: "Accessibility label for insert link button on formatting toolbar.")
        case .horizontalruler:
            return NSLocalizedString("Insert Horizontal Ruler", comment: "Accessibility label for insert horizontal ruler button on formatting toolbar.")
        case .sourcecode:
            return NSLocalizedString("HTML", comment:"Accessibility label for HTML button on formatting toolbar.")
        case .more:
            return NSLocalizedString("More", comment:"Accessibility label for the More button on formatting toolbar.")
        case .header1:
            return NSLocalizedString("Heading 1", comment: "Accessibility label for selecting h1 paragraph style button on the formatting toolbar.")
        case .header2:
            return NSLocalizedString("Heading 2", comment: "Accessibility label for selecting h2 paragraph style button on the formatting toolbar.")
        case .header3:
            return NSLocalizedString("Heading 3", comment: "Accessibility label for selecting h3 paragraph style button on the formatting toolbar.")
        case .header4:
            return NSLocalizedString("Heading 4", comment: "Accessibility label for selecting h4 paragraph style button on the formatting toolbar.")
        case .header5:
            return NSLocalizedString("Heading 5", comment: "Accessibility label for selecting h5 paragraph style button on the formatting toolbar.")
        case .header6:
            return NSLocalizedString("Heading 6", comment: "Accessibility label for selecting h6 paragraph style button on the formatting toolbar.")
        case .code:
            return NSLocalizedString("Code", comment: "Accessibility label for selecting code style button on the formatting toolbar.")
        default:
            return ""
        }
    }
}


