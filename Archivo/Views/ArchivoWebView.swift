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

        // User Script: Native App Behavior without breaking touch scroll gestures
        let nativeAppCSS = """
        var style = document.createElement('style');
        style.innerHTML = `
            body {
                -webkit-touch-callout: none;
                -webkit-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
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
            .content, .scrollable, [data-scrollable="true"], .login-page, .login-shell {
                -webkit-overflow-scrolling: touch !important;
                touch-action: pan-y !important;
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
        webView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)

        // Essential: Allow full edge-to-edge content bleed behind dynamic island, notch, and home bar
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Native iOS fluid touch momentum scrolling
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Standard Mobile Safari User Agent so Cloudflare WAF never flags requests
        let defaultUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 ArchivoNative"
        webView.customUserAgent = defaultUA

        context.coordinator.webView = webView

        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
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

        init(_ parent: ArchivoWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onLoadingChange?(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadingChange?(false)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onLoadingChange?(false)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
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
