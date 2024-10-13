import UIKit
import WebKit
import SnapKit

final class FacilityInfoViewController: CustomViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    // MARK: UI Components
    
    private var webView = WKWebView()
    private var backgroundView = UIView()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setUpNavigationBar()
        setNavigationTitle(title: "교내 시설물 정보")
        loadWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
    }
    
    private func loadWebView() {
        if let url = URL(string: "http://koreatech.in/campusinfo") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let disableZoomCode = "document.querySelector('meta[name=viewport]').setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');"
                webView.evaluateJavaScript(disableZoomCode, completionHandler: nil)
    }
}

extension FacilityInfoViewController {
    private func setUpLayOuts() {
        [navigationBarWrappedView, backgroundView].forEach {
            view.addSubview($0)
        }
        backgroundView.addSubview(webView)
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
        backgroundView.backgroundColor = .white
    }
}
