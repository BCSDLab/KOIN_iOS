//
//  OrderResultWebViewController.swift
//  koin
//
//  Created by 이은지 on 9/15/25.
//

import UIKit
import WebKit
import Combine

final class OrderResultWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private let resultURL: URL
    private var subscriptions: Set<AnyCancellable> = []

    private let checkLoginUseCase = DefaultCheckLoginUseCase(
        userRepository: DefaultUserRepository(service: DefaultUserService())
    )

    private let webView: NoInputAccessoryWKWebView = {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true

        let webView = NoInputAccessoryWKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    init(resultURL: URL) {
        self.resultURL = resultURL
        super.init(nibName: nil, bundle: nil)
        self.title = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        checkLoginAndLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

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

    private func checkLoginAndLoad() {
        checkLoginUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion { self.clearWebDataAndLoad() }
            } receiveValue: { [weak self] isLoggedIn in
                guard let self else { return }
                isLoggedIn ? self.setTokenCookiesAndLoad() : self.clearWebDataAndLoad()
            }
            .store(in: &subscriptions)
    }

    private func clearWebDataAndLoad() {
        let all = WKWebsiteDataStore.allWebsiteDataTypes()
        let store = WKWebsiteDataStore.default()
        store.fetchDataRecords(ofTypes: all) { records in
            guard !records.isEmpty else { self.loadResultPage(); return }
            store.removeData(ofTypes: all, for: records) { self.loadResultPage() }
        }
    }

    private func setTokenCookiesAndLoad() {
        let access = KeychainWorker.shared.read(key: .access) ?? ""
        let refresh = KeychainWorker.shared.read(key: .refresh) ?? ""

        guard !access.isEmpty, !refresh.isEmpty else {
            loadResultPage()
            return
        }

        let domain = "order.stage.koreatech.in"
        let accessCookie = HTTPCookie(properties: [
            .domain: domain, .path: "/", .name: "AUTH_TOKEN_KEY", .value: access,
            .secure: true, .expires: Date(timeIntervalSinceNow: 60 * 60)
        ])!
        let refreshCookie = HTTPCookie(properties: [
            .domain: domain, .path: "/", .name: "refreshToken", .value: refresh,
            .secure: true, .expires: Date(timeIntervalSinceNow: 60 * 60 * 24 * 14)
        ])!

        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let group = DispatchGroup()
        [accessCookie, refreshCookie].forEach { cookie in
            group.enter(); cookieStore.setCookie(cookie) { group.leave() }
        }
        group.notify(queue: .main) { [weak self] in self?.loadResultPage() }
    }

    private func loadResultPage() {
        let request = URLRequest(url: resultURL)
        webView.load(request)
    }

    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("주문상세 로딩 실패: \(error.localizedDescription)")
    }

    // MARK: WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "tokenBridge",
              let body = message.body as? String,
              let data = body.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = payload["method"] as? String
        else { return }

        switch method {
        case "navigateBack":
            if presentingViewController != nil {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        case "getUserTokens":
            let accessToken = KeychainWorker.shared.read(key: .access) ?? ""
            let refreshToken = KeychainWorker.shared.read(key: .refresh) ?? ""
            let callbackId = payload["callbackId"] as? String ?? ""
            let dictionary: [String: Any] = ["access": accessToken, "refresh": refreshToken]
            let resultData = try? JSONSerialization.data(withJSONObject: dictionary)
            let resultString = resultData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
            let script = """
            if (window.onNativeCallback) {
              window.onNativeCallback('\(callbackId)', \(resultString));
            }
            """
            webView.evaluateJavaScript(script, completionHandler: nil)

        default:
            break
        }
    }
}
