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
    private var didSendTokens = false
    private let webView: WKWebView = {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadClubPage()
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
        // message handler 재등록
        if let controller = webView.configuration.userContentController as? WKUserContentController {
            controller.removeScriptMessageHandler(forName: "tokenBridge")
            controller.add(LeakAvoider(delegate: self), name: "tokenBridge")
        }

        webView.navigationDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadClubPage() {
        guard let url = URL(string: "https://koreatech.in/clubs") else {
            print("❌ 유효하지 않은 URL입니다.")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    func sendTokensToWeb(access: String, refresh: String) {
        let escapedAccess = access.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        let escapedRefresh = refresh.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
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

// MARK: - WKNavigationDelegate
extension ClubWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🌐 웹 페이지 로딩 완료")
        guard !didSendTokens else { return }
            didSendTokens = true

            let token = KeychainWorker.shared.read(key: .access) ?? ""
            let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
            self.sendTokensToWeb(access: token, refresh: refresh)
    }
}

// MARK: - JS 통신 처리
extension ClubWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                              didReceive message: WKScriptMessage) {

        guard message.name == "tokenBridge" else { return }
        guard let bodyString = message.body as? String,
              let data = bodyString.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = payload["method"] as? String,
              let callbackId = payload["callbackId"] as? String else {
            return
        }
        print(method)
        let args = payload["args"] as? [Any] ?? []

        switch method {
        case "getUserToken":
            let access = KeychainWorker.shared.read(key: .access) ?? ""
            let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
            sendCallbackToWeb(callbackId: callbackId, result: ["access": access, "refresh": refresh])
        case "getRefreshToken":
            if let tokenData = args.first as? [String: String] {
                KeychainWorker.shared.create(key: .access, token: tokenData["access"] ?? "")
                KeychainWorker.shared.create(key: .refresh, token: tokenData["refresh"] ?? "")
                sendCallbackToWeb(callbackId: callbackId, result: ["success": true])
            }
        case "backButtonTapped":
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            sendCallbackToWeb(callbackId: callbackId, result: ["success": true])

        default:
            print("⚠️ 지원되지 않는 메서드: \(method)")
        }
    }

    private func sendCallbackToWeb(callbackId: String, result: Any) {
        do {
            let resultData = try JSONSerialization.data(withJSONObject: result)
            let resultString = String(data: resultData, encoding: .utf8) ?? "{}"
            let js = "window.setTokens('\(callbackId)', \(resultString))"

            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(js) { _, error in
                    if let error = error {
                        print("콜백 전송 실패: \(error)")
                    }
                }
            }
        } catch {
            print("JSON 직렬화 실패: \(error)")
        }
    }
}
