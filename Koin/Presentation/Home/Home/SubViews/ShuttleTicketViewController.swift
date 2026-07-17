//
//  ShuttleTicketViewController.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import UIKit
import WebKit
import SnapKit
import Then

final class ShuttleTicketViewController: UIViewController {
    
    // MARK: - Properties
    private let initialURL = "https://koreatech.unibus.kr/#!/index"
    private let qrViewAreaMessage = "qrViewAreaVisibility"
    private let qrViewAreaObserverScript =
        """
        (() => {
            const messageHandler = window.webkit?.messageHandlers?.qrViewAreaVisibility;
            if (!messageHandler) return;
        
            let previousVisibility;
        
            const notifyVisibility = () => {
                const isVisible = document.querySelector('.qrViewArea') !== null;
                if (previousVisibility === isVisible) return;
        
                previousVisibility = isVisible;
                messageHandler.postMessage(isVisible);
            };
        
            const observer = new MutationObserver(notifyVisibility);
            observer.observe(document.documentElement, {
                childList: true,
                subtree: true
            });
            notifyVisibility();
        })();
        """
    private var brightnessBeforeQRCode: CGFloat?
    private var isQRCodeVisible = false

    // MARK: - UI Components
    private lazy var webView: WKWebView = {
        let userContentController = WKUserContentController()
        let qrViewAreaObserverScript = WKUserScript(
            source: qrViewAreaObserverScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(qrViewAreaObserverScript)
        userContentController.add(self, name: qrViewAreaMessage)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.websiteDataStore = .default()

        return WKWebView(frame: .zero, configuration: configuration)
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setUpObserver()
        loadInitialPage()
        navigationItem.title = "셔틀 탑승권"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .shuttleTicket)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreBrightness()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard isMovingFromParent || navigationController?.isBeingDismissed == true else { return }
        webView.configuration.userContentController.removeScriptMessageHandler(
            forName: qrViewAreaMessage
        )
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension ShuttleTicketViewController {

    private func configureView() {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setUpObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func loadInitialPage() {
        guard let url = URL(string: initialURL) else { return }
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - @Objc
    @objc private func applicationWillResignActive() {
        restoreBrightness()
    }

    @objc private func applicationDidBecomeActive() {
        updateBrightnessForCurrentState()
    }
}

private extension ShuttleTicketViewController {

    // MARK: - QR 상태 변화시 밝기 변화
    private func updateQRCodeVisibility(_ isVisible: Bool) {
        guard isQRCodeVisible != isVisible else { return }
        isQRCodeVisible = isVisible
        updateBrightnessForCurrentState()
    }

    // MARK: - 상태에 따라 밝기 변화
    private func updateBrightnessForCurrentState() {
        guard isQRCodeVisible, UIApplication.shared.applicationState == .active else {
            restoreBrightness()
            return
        }
        maximizeBrightness()
    }

    // MARK: - 밝기 최대화
    private func maximizeBrightness() {
        guard brightnessBeforeQRCode == nil else { return }
        brightnessBeforeQRCode = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }

    // MARK: - 밝기 복구
    private func restoreBrightness() {
        guard let brightnessBeforeQRCode else { return }
        UIScreen.main.brightness = brightnessBeforeQRCode
        self.brightnessBeforeQRCode = nil
    }
}

extension ShuttleTicketViewController: WKScriptMessageHandler {

    // MARK: - QR 상태 수신
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == qrViewAreaMessage,
              let isVisible = (message.body as? NSNumber)?.boolValue else { return }
        updateQRCodeVisibility(isVisible)
    }
}
