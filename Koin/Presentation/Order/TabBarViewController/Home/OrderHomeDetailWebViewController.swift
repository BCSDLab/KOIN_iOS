//
//  OrderHomeDetailWebViewController.swift
//  koin
//
//  Created by 이은지 on 7/12/25.
//

import UIKit
import WebKit
import Combine

final class OrderHomeDetailWebViewController: UIViewController, UIGestureRecognizerDelegate {
    private var subscriptions: Set<AnyCancellable> = []
    private weak var originalPopGestureDelegate: UIGestureRecognizerDelegate?
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
        webView.allowsBackForwardNavigationGestures = true
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
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.tabBarController?.navigationController?.setNavigationBarHidden(false, animated: animated)
            self.tabBarController?.tabBar.isHidden = false
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = originalPopGestureDelegate
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func checkLoginAndLoadPage() {
        checkLoginUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    self.clearWebViewCacheAndLoad()
                }
            }, receiveValue: { [weak self] isLoggedIn in
                guard let self else { return }
                if isLoggedIn {
                    self.setTokenCookieAndLoadPage()
                } else {
                    self.clearWebViewCacheAndLoad()
                }
            })
            .store(in: &subscriptions)
    }

    private func clearWebViewCacheAndLoad() {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: dataTypes) { records in
            if records.isEmpty {
                self.loadShopDetailPage()
            } else {
                WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, for: records) {
                    self.loadShopDetailPage()
                }
            }
        }
    }

    private func setTokenCookieAndLoadPage() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""

        if access.isEmpty || refresh.isEmpty {
            print("비로그인 상태")
            loadShopDetailPage()
            return
        }

        let accessCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "AUTH_TOKEN_KEY",
            .value: access,
            .secure: true,
            .expires: Date(timeIntervalSinceNow: 60 * 60)
        ])!

        let refreshCookie = HTTPCookie(properties: [
            .domain: "order.stage.koreatech.in",
            .path: "/",
            .name: "refreshToken",
            .value: refresh,
            .secure: true,
            .expires: Date(timeIntervalSinceNow: 60 * 60 * 24 * 14)
        ])!

        let cookies = [accessCookie, refreshCookie]
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let group = DispatchGroup()

        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.loadShopDetailPage()
        }
    }

    private func loadShopDetailPage() {
        guard let shopId = shopId else { return }

        let urlString = isFromOrder
            ? "https://order.stage.koreatech.in/shop/true/\(shopId)"
            : "https://order.stage.koreatech.in/shop/false/\(shopId)"
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)

        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }
}

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
            self.navigationController?.popViewController(animated: true)
        case "getUserTokens":
            sendTokensToWebView(callbackId: payload["callbackId"] as? String)
        case "redirectToLogin":
            let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            loginViewController.title = "로그인"
            loginViewController.completion = { [weak self] in
                guard let self = self else { return }
                let orderCartWebViewController = OrderCartWebViewController()
                orderCartWebViewController.title = "장바구니"
                self.navigationController?.pushViewController(orderCartWebViewController, animated: true)
            }
            navigationController?.pushViewController(loginViewController, animated: true)
        default:
            print("지원되지 않는 메서드: \(method)")
        }
    }
    
    private func sendTokensToWebView(callbackId: String?) {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""
     
        guard let callbackId else { return }
        let resultDict: [String: Any] = [
            "access": access,
            "refresh": refresh,
        ]
        let resultData = try? JSONSerialization.data(withJSONObject: resultDict)
        let resultString = resultData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        
        let script = """
                    if (window.onNativeCallback) {
                    window.onNativeCallback('\(callbackId)', \(resultString));
                    }
                    """
       
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("토큰 전달 실패: \(error)")
            } else {
                print("토큰 전달 성공 (callbackId: \(callbackId))")
            }
        }
    }
}
