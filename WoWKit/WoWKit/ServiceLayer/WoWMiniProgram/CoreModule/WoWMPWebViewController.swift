//
//  WoWMiniWebViewController.swift
//  WoW-Example
//  小程序
//  Created by Silence on 2020/11/4.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import WoWKitDependency

class WoWMiniWebViewController: UIViewController {
    static func createWebPage(appId: String, webviewId: Int) -> WoWMiniWebViewController {
        return WoWMiniWebViewController(appId: appId, webviewId: webviewId)
    }
    
    var webView: WoWMiniWebView?
    
    // Vue 实例是否已经初始化完成
    var isReady: Bool = false
    
    // appId: 用于 webview 调用原生时找到对应的 MiniProgramController
    let appId: String
    
    // webviewId: 用于对应 JSContext 找到对应的 PageViewController
    let webviewId: Int
    
    // ready 以前把脚本记录
    var scrips: [String] = []
    
    var htmlContent: String = ""
    
    var queryOption: [String: String] = [:]
    
    init(appId: String, webviewId: Int) {
        self.appId = appId
        self.webviewId = webviewId
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PageLifeCycle.onAppear.
    }
}
