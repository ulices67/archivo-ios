import SwiftUI
import WebKit

struct ArchivoWebView: UIViewRepresentable {
    let url: URL
    var onLoadingChange: ((Bool) -> Void)? = nil

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true

        // Native App Behavior styling injection
        let nativeAppCSS = """
        var style = document.createElement('style');
        style.innerHTML = `
            html, body {
                margin: 0 !important;
                padding: 0 !important;
                width: 100% !important;
                height: 100% !important;
                -webkit-touch-callout: none;
                -webkit-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
                background-color: #121312 !important;
            }
            input, textarea, [contenteditable="true"], .selectable-text {
                -webkit-user-select: text !important;
                user-select: text !important;
                -webkit-touch-callout: default !important;
            }
            img, svg, picture {
                -webkit-user-drag: none !important;
                -webkit-touch-callout: none !important;
                user-select: none !important;
            }
            .content, .scrollable, [data-scrollable="true"], .login-page, .login-shell, .app-shell, .phone-frame {
                -webkit-overflow-scrolling: touch !important;
            }
        `;
        document.head.appendChild(style);
        """
        let userScript = WKUserScript(source: nativeAppCSS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.07, green: 0.075, blue: 0.07, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.07, green: 0.075, blue: 0.07, alpha: 1.0)

        // Allow edge-to-edge content bleed behind dynamic island and home bar
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Fluid touch momentum scrolling
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Pull to refresh support
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        // Standard Mobile Safari User Agent
        let defaultUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 ArchivoNative"
        webView.customUserAgent = defaultUA

        context.coordinator.webView = webView
        context.coordinator.refreshControl = refreshControl

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData
        request.timeoutInterval = 30
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: ArchivoWebView
        weak var webView: WKWebView?
        weak var refreshControl: UIRefreshControl?

        init(_ parent: ArchivoWebView) {
            self.parent = parent
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            guard let webView = webView else {
                sender.endRefreshing()
                return
            }
            var request = URLRequest(url: parent.url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            webView.load(request)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onLoadingChange?(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            refreshControl?.endRefreshing()
            parent.onLoadingChange?(false)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            refreshControl?.endRefreshing()
            parent.onLoadingChange?(false)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            refreshControl?.endRefreshing()
            parent.onLoadingChange?(false)
        }

        // Open target="_blank" links within the same webview
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
