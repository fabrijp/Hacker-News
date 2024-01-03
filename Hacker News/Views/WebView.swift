//
//  WebView.swift
//  News
//
//  Created by Alexandre Fabri on 2021/09/25.
//

import SwiftUI
import WebKit

/// Custom WKWebView controller to load story article
struct WebView: UIViewRepresentable {
    
    // Flag to keep track of the ProgresView
    @Binding var finished: Bool
    // The story url
    let urlString: String?
    
    @State private var webView: WKWebView?
    
    func makeUIView(context: Context) -> WKWebView  {
        let userContentController = addUserScripts()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        DispatchQueue.main.async {
            self.webView = webView
        }
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let urlString = urlString, let url = URL(string: urlString) {
            // Load page
            webView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func goBack(){
        webView?.goBack()
    }
    
    func goForward(){
        webView?.goForward()
    }
    
    private func addUserScripts() -> WKUserContentController {
        let userContentController = WKUserContentController()
        
        // Try to disable autoplay of videos
        let script = WKUserScript(source: "document.querySelectorAll('video').forEach(v => v.pause());", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(script)
        
        return userContentController
    }
    
    // Delegation
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        // If we need to handle request errors, here is the place for that.
        // For now we assume the page is done loading.
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.parent.finished = true
        }
        
        // The page finished loading
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.finished = true
        }
        
        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}
