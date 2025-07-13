//
//  OrderCartWebViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import Combine
import UIKit
import WebKit

final class OrderCartWebViewController: UIViewController, WKUIDelegate {
    private var subscriptions: Set<AnyCancellable> = []
    private let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))

    private let webView: NoInputAccessoryWKWebView = {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = NoInputAccessoryWKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.configuration.allowsInlineMediaPlayback = true
        return webView
    }()

    override var inputAccessoryView: UIView? {
        return nil
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        checkLogin()
        print("웹뷰 진입")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func checkLogin() {
        checkLoginUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            setupWebView()
            loadCartPage()
        }.store(in: &subscriptions)
    }

    private func loadCartPage() {
        guard let url = URL(string: "https://order.stage.koreatech.in/cart") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate
extension OrderCartWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로딩 완료")
    }
}

// MARK: - JS 통신 처리
extension OrderCartWebViewController: WKScriptMessageHandler {
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
        
        print("iOS에서 받은 method: ", method)
        print("iOS에서 받은 raw 메시지: \(message.body)")
        let args = payload["args"] as? [Any] ?? []

        switch method {
        case "getUserTokens":
            let access = KeychainWorker.shared.read(key: .access) ?? ""
            let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
            sendTokensToWeb(access: access, refresh: refresh)
        case "putUserToken":
            if let tokenData = args.first as? [String: String] {
                KeychainWorker.shared.create(key: .access, token: tokenData["access"] ?? "")
                KeychainWorker.shared.create(key: .refresh, token: tokenData["refresh"] ?? "")
            }
        case "backButtonTapped":
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        default:
            print("지원되지 않는 메서드: \(method)")
        }
    }

    func sendTokensToWeb(access: String, refresh: String) {
        let escapedAccess = access.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        let escapedRefresh = refresh.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        let js = "window.setTokens('\(escapedAccess)', '\(escapedRefresh)')"
        print(js)
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("JavaScript 전송 실패: \(error)")
            } else {
                print("토큰 전달 성공")
            }
        }
    }
}

extension OrderCartWebViewController {
    private func setupWebView() {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "tokenBridge")
        webView.configuration.userContentController.add(LeakAvoider(delegate: self), name: "tokenBridge")
        webView.navigationDelegate = self
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
