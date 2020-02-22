//
//  HTMLViewController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import UIKit
import SwiftUI
import WebKit

struct HTMLView: UIViewControllerRepresentable {
    var controller = HTMLViewControler()
    
    func makeUIViewController(context: Context) -> HTMLViewControler {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: HTMLViewControler, context: Context) {
        
    }
    
    func loadHTML(_ htmlContent: String) {
        controller.loadHTML(htmlContent)
    }
    
    
    typealias UIViewControllerType = HTMLViewControler
    
}

final class HTMLViewControler: UIViewController {
    private lazy var webview: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let webview = WKWebView(frame: .zero, configuration: configuration)
        webview.translatesAutoresizingMaskIntoConstraints = false
        return webview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    private func setupViews() {
        view.addSubview(webview)
        NSLayoutConstraint.activate([
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.topAnchor.constraint(equalTo: view.topAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadHTML(_ htmlContent: String) {
            let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0'></header>"
        let styleString = """
    <style type='text/css'>
        img {
            max-width: 100%;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        }
        
        </style>
<body>
"""
            webview.loadHTMLString(headerString+styleString + htmlContent + "</body>", baseURL: nil)
    }

    @objc private func contentSizeDidChange(_ notification: Notification) {
        webview.reload()
    }
}
