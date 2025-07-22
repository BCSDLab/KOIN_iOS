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

    override var inputAccessoryView: UIView? { nil }

    init(shopId: Int?) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.appColor(.newBackground)
        checkLogin()
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
        checkLoginUseCase.execute()
            .sink { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.setupWebView()
                self.setTokenCookieAndLoadPage()
            }
            .store(in: &subscriptions)
    }

    private func setTokenCookieAndLoadPage() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""

        // accessToken 쿠키 세팅
        let accessCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "AUTH_TOKEN_KEY",
            .value: access,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60) // 1시간 후 만료
        ])!

        // refreshToken 쿠키 세팅
        let refreshCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "refreshToken",
            .value: refresh,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 14) // 2주 후 만료
        ])!

        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.setCookie(accessCookie) {
            cookieStore.setCookie(refreshCookie) { [weak self] in
                self?.loadShopDetailPage()
            }
        }
    }

    private func loadShopDetailPage() {
        guard let shopId = shopId,
              let url = URL(string: "https://order.stage.koreatech.in/shop/\(shopId)") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WebView 세팅
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

// MARK: - WKNavigationDelegate (필요 없으면 비워둬도 됨)
extension OrderHomeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로딩 완료")
    }
}

// MARK: - JS 통신 처리 (navigateBack 등만 남김)
extension OrderHomeDetailViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "tokenBridge",
              let bodyString = message.body as? String,
              let data = bodyString.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = payload["method"] as? String else { return }

        switch method {
        case "navigateBack", "finish", "backButtonTapped":
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        default:
            print("지원되지 않는 메서드: \(method)")
        }
    }
}
