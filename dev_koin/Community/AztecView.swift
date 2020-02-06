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
}


