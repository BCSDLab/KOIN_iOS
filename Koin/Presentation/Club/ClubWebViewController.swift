//
//  ClubWebViewController.swift
//  koin
//
//  Created by 김나훈 on 6/9/25.
//

import UIKit
import WebKit

final class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

final class ClubWebViewController: UIViewController {
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadClubPage()
        setupWebView()
        addBlueSafeAreaView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "tokenBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadClubPage() {
        guard let url = URL(string: "https://stage.koreatech.in/clubs") else {
            print("❌ 유효하지 않은 URL입니다.")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func sendTokensToWeb(access: String, refresh: String) {
        let escapedAccess  = access.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        let escapedRefresh = refresh.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        print(access)
        print(escapedAccess)
        let js = "window.setTokens('\(escapedAccess)', '\(escapedRefresh)')"
        print(js)
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("⚠️ JavaScript 전송 실패: \(error)")
            } else {
                print("✅ 토큰 전달 성공")
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension ClubWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🌐 웹 페이지 로딩 완료")
        let token = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
    //    self.sendTokensToWeb(access: token, refresh: refresh)
    }
}

// MARK: - JS 통신 처리
extension ClubWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        print(message)
        guard message.name == "tokenBridge" else { return }
        guard let body = message.body as? String else { return }
        
        if body.hasPrefix("saveTokens:") {
            let jsonString = String(body.dropFirst("saveTokens:".count))
            if let data = jsonString.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                let access = dict["access"] ?? ""
                let refresh = dict["refresh"] ?? ""
                KeychainWorker.shared.create(key: .access, token: access)
                KeychainWorker.shared.create(key: .refresh, token: refresh)
                print("🔐 iOS Keychain 저장 완료")
            }
            return
        }
        
        switch body {
        case "getUserToken":
            let token = KeychainWorker.shared.read(key: .access) ?? ""
            sendTokensToWeb(access: token, refresh: "")
        case "getRefreshToken":
            let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
            sendTokensToWeb(access: "", refresh: refresh)
        default:
            print("⚠️ 지원되지 않는 메서드 요청: \(body)")
        }
    }
    private func addBlueSafeAreaView() {
        let blueView = UIView()
        blueView.backgroundColor = .systemBlue
        blueView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueView)

        NSLayoutConstraint.activate([
            blueView.topAnchor.constraint(equalTo: view.topAnchor),
            blueView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            blueView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            blueView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
