//
//  OrderHomeDetailWebViewController.swift
//  koin
//
//  Created by 이은지 on 7/12/25.
//

import Combine
import UIKit
import WebKit

final class OrderHomeDetailWebViewController: UIViewController {
    private var subscriptions: Set<AnyCancellable> = []
    private let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let shopId: Int?
    private let isFromOrder: Bool

    private let webView: NoInputAccessoryWKWebView = {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()

        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePreferences

        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true

        let webView = NoInputAccessoryWKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override var inputAccessoryView: UIView? { nil }

    init(shopId: Int?, isFromOrder: Bool) {
        self.shopId = shopId
        self.isFromOrder = isFromOrder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.appColor(.newBackground)
        setupWebView()
        checkLoginAndLoadPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func checkLoginAndLoadPage() {
        checkLoginUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    print("🔓 비로그인 상태 (오류)로 웹뷰 로드")
                    self?.loadShopDetailPage(withCookies: [])
                }
            }, receiveValue: { [weak self] isLoggedIn in
                if isLoggedIn {
                    print("🔐 로그인 상태")
                    self?.setTokenCookieAndLoadPage()
                } else {
                    print("🔓 비로그인 상태 (정상 응답)")
                    self?.loadShopDetailPage(withCookies: [])
                }
            })
            .store(in: &subscriptions)
    }

    private func setTokenCookieAndLoadPage() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""

        let accessCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "AUTH_TOKEN_KEY",
            .value: access,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60)
        ])!

        let refreshCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "refreshToken",
            .value: refresh,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 14)
        ])!

        loadShopDetailPage(withCookies: [accessCookie, refreshCookie])
    }

    private func loadShopDetailPage(withCookies cookies: [HTTPCookie]) {
        guard let shopId = shopId else { return }
        let urlString = isFromOrder
            ? "https://order.stage.koreatech.in/shop/true/\(shopId)"
            : "https://order.stage.koreatech.in/shop/false/\(shopId)"
        print("웹뷰 URL: ", urlString)
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

        if cookies.isEmpty {
            print("🍪 쿠키 없이 로딩 (비로그인)")
            DispatchQueue.main.async {
                self.webView.load(request)
            }
            return
        }

        let group = DispatchGroup()
        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("🍪 쿠키 설정 완료 후 로딩")
            self.webView.load(request)
        }
        
    }
}

// MARK: - WebView 세팅
extension OrderHomeDetailWebViewController {
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

// MARK: - WKNavigationDelegate
extension OrderHomeDetailWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로딩 완료")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("웹 페이지 로딩 실패: \(error.localizedDescription)")
    }
}

// MARK: - JS 통신 처리
extension OrderHomeDetailWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "tokenBridge",
              let bodyString = message.body as? String,
              let data = bodyString.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = payload["method"] as? String else { return }

        switch method {
        case "navigateBack":
            navigateBackButtonTapped()
        case "getUserTokens":
            sendTokensToWebView()
        default:
            print("지원되지 않는 메서드: \(method)")
        }
    }
    
    private func navigateBackButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func sendTokensToWebView() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""

        let script = """
        if (window.onReceiveTokens) {
            window.onReceiveTokens({
                accessToken: "\(access)",
                refreshToken: "\(refresh)"
            });
        }
        """
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("토큰 전달 실패: \(error)")
            } else {
                print("✅ 토큰 전달 성공")
            }
        }
    }
}
