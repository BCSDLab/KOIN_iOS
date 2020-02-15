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
        print(context)
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


