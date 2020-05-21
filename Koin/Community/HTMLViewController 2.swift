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
        controller.reload()
    }
    
    func loadHTML(_ htmlContent: String) {
        controller.loadHTML(htmlContent)
    }
    
    func getObservation() -> NSKeyValueObservation? {
        return controller.observation
    }
    
    
    typealias UIViewControllerType = HTMLViewControler
    
}

final class HTMLViewControler: UIViewController {
    var observation: NSKeyValueObservation?
    var activityIndicator = UIActivityIndicatorView()
    
    private lazy var webview: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let webview = WKWebView(frame: .zero, configuration: configuration)
        webview.translatesAutoresizingMaskIntoConstraints = false
        return webview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        setupViews()

        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        observation = webview.observe(\WKWebView.estimatedProgress, options: .new) { _, change in
            print("Loaded: \(change)")
        }
    }
    
    deinit {
        self.observation = nil
    }
    
    func reload() {
        webview.reload()
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
            webview.allowsBackForwardNavigationGestures = true
    }

    @objc private func contentSizeDidChange(_ notification: Notification) {
        webview.reload()
    }
}

extension HTMLViewControler: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 1. 가운데 로딩 이미지를 띄워주면서
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.frame = CGRect(x: view.frame.midX - 25, y: view.frame.midY - 25 , width: 50, height: 50)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // 1. 제거
        self.activityIndicator.removeFromSuperview()
        
        // 2. 제거
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
