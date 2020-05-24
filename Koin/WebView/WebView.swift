import SwiftUI
import WebKit

struct WebView: UIViewRepresentable{
    @Binding var htmlString: String
    @Binding var baseURL: URL?
    let webView = WKWebView()

    func makeUIView(context: Context) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if self.htmlString != context.coordinator.lastLoadedHTML {
            context.coordinator.lastLoadedHTML = self.htmlString
            uiView.loadHTMLString(self.htmlString, baseURL: self.baseURL)
        }
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastLoadedHTML = ""


        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, url != URL(string: "about:blank") {
                decisionHandler(.cancel)
                UIApplication.shared.open(url as URL)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

