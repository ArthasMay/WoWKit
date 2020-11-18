//
//  WoWMiniWebViewController.swift
//  WoW-Example
//  小程序
//  Created by Silence on 2020/11/4.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import WoWKitDependency
import WebKit

class WoWMiniWebViewController: UIViewController {
    static func createWebPage(appId: String, webViewId: Int) -> WoWMiniWebViewController {
        return WoWMiniWebViewController(appId: appId, webViewId: webViewId)
    }
    
    var webView: WoWMiniWebView?
    
    // Vue 实例是否已经初始化完成
    var isReady: Bool = false
    
    // appId: 用于 webview 调用原生时找到对应的 MiniProgramController
    let appId: String
    
    // webViewId: 用于对应 JSContext 找到对应的 PageViewController
    let webViewId: Int
    
    // ready 以前把脚本记录
    var scripts: [String] = []
    
    var htmlContent: String = ""
    
    var queryOption: [String: String] = [:]
    
    init(appId: String, webViewId: Int) {
        self.appId = appId
        self.webViewId = webViewId
        logger.info("🧲 init")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 设置特定的导航栏
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let controller = WKUserContentController()
        controller.add(self, name: "trigger")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = controller
        
        webView = WoWMiniWebView(frame: view.bounds, configuration: configuration)
        webView!.uiDelegate = self
        webView!.navigationDelegate = self
        view.addSubview(webView!)
        logger.info("🧲 did load")
        
        if !htmlContent.isEmpty {
            loadHTML(htmlContent: htmlContent)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PageLifeCycle.onAppear.load(appId: appId, webViewController: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PageLifeCycle.onDisappear.load(appId: appId, webViewController: self)
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "trigger")
    }
    
    // MARK: - Private Methods
    
    /// 在 WebView 的JSVM中执行js脚本
    /// - Parameter script: js
    private func run(script: String) {
        webView?.evaluateJavaScript(script, completionHandler: { (data, error) in
            if error != nil {
                logger.error(error)
            }
        })
    }
    
    /// WebView 加载本地的HTML
    /// - Parameter htmlContent: html
    private func loadHTML(htmlContent: String) {
        webView?.loadHTMLString(htmlContent, baseURL: URL(string: "http://localhost"))
        PageLifeCycle.onReady.load(appId: appId, webViewController: self)
    }
    
    // MARK: - Public Methods
    public func load(pagePath: String) {
        guard let url = URL(string: pagePath) else {
            logger.error("【WoWMP】: 加载路径异常")
            return
        }
        
        queryOption = url.wowQuery
        let basePath = url.path
        
        var error: Error?
        let htmlContent = WoWFileReader.shared.readFileContent(appId: appId, fileName: basePath.appending("/index.html"), error: &error)
        if error != nil {
            logger.error(error)
            return
        }
        PageLifeCycle.onLoad.load(appId: appId, webViewController: self)
        if webView == nil {
            self.htmlContent = htmlContent
            return
        }
        loadHTML(htmlContent: htmlContent)
    }
    
    /// 更新小程序页面渲染
    /// - Parameter data: JSON 字符串
    public func setData(data: String) {
        let script = "window.__setData(\(data))"
        if !isReady {
            scripts.append(script)
            return
        }
        run(script: script)
    }
    
    /// VM 实例化之后调用
    public func ready() {
        self.isReady = true
        self.scripts.forEach { (script) in
            self.run(script: script)
        }
    }
}

extension WoWMiniWebViewController: WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "trigger":
            let option = WebViewInvokeNativeOption(JSONString: message.body as? String ?? "")
            option?.invoke(target: self)
        default:
            break
        }
    }
}
