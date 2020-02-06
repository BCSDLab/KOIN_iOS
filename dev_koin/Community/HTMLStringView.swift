//
//  HTMLStringView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import WebKit
import SwiftUI
import UIKit

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let wview: WKWebView = {
          let preferences = WKPreferences()
          preferences.javaScriptEnabled = false
          let configuration = WKWebViewConfiguration()
          configuration.preferences = preferences
          let webview = WKWebView(frame: .zero, configuration: configuration)
          webview.translatesAutoresizingMaskIntoConstraints = false
          return webview
        }()
        wview.sizeToFit()
        wview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return wview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
