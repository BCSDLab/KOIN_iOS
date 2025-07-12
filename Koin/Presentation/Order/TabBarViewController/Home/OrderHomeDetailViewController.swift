//
//  OrderHomeDetailViewController.swift
//  koin
//
//  Created by 이은지 on 7/12/25.
//

import Combine
import UIKit
import WebKit

final class OrderHomeDetailViewController: UIViewController {
    private var didSendTokens = false
    private var subscriptions: Set<AnyCancellable> = []
    private let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let shopId: Int?

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

    init(shopId: Int?) {
        self.shopId = shopId
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
            loadShopDetailPage()
        }.store(in: &subscriptions)
    }

    private func loadShopDetailPage() {
        guard let shopId = shopId else { return }
        guard var components = URLComponents(string: Bundle.main.baseUrl) else {
            return
        }
        if let originalHost = components.host {
            let updatedHost = originalHost.replacingOccurrences(of: "api.", with: "")
            components.host = updatedHost
        }

        components.path = "/order/shop/\(shopId)"

        guard let url = components.url else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate
extension OrderHomeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로딩 완료")
        sendTokensToWeb()
    }
}

// MARK: - JS 통신 처리
extension OrderHomeDetailViewController: WKScriptMessageHandler {
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
        print("\(message.body)")
        let args = payload["args"] as? [Any] ?? []

        switch method {
        case "getUserToken":
            sendTokensToWeb()
        case "backButtonTapped":
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        case "putUserToken":
            if let tokenData = args.first as? [String: String] {
                KeychainWorker.shared.create(key: .access, token: tokenData["access"] ?? "")
                KeychainWorker.shared.create(key: .refresh, token: tokenData["refresh"] ?? "")
            }
        default:
            print("지원되지 않는 메서드: \(method)")
        }
    }

    func sendTokensToWeb() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
        let tokenInfo: [String: String] = [
            "accessToken": access,
            "refreshToken": refresh
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: tokenInfo, options: []),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        
        let js = "window.postMessage('\(jsonString)\')"
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

extension OrderHomeDetailViewController {
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
