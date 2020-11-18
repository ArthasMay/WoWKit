//
//  WoWMPEngine.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/16.
//

import UIKit
import JavaScriptCore
import WoWKitDependency

class WoWMPEngine {
    let appId: String
    
    // Mini Program全局添加的执行逻辑的JSContext，对应一个区别于WKWebView的JSVM, 可以在原生中执行多线程并发操作
    let JSCContext: JSContextWrapper
    
    var routeStack: [WoWMiniWebViewController] = []
    var rootViewController: UINavigationController?
    
    // 标记页面的id，可以完善复用的逻辑
    var uid = 0
    var launched = false
    
    init(appId: String) {
        self.appId = appId
        var error: Error? = nil
        let scriptContent = WoWFileReader.shared.readFileContent(appId: appId, fileName: "main.js", error: &error)
        if error != nil {
            logger.error(error)
        }
        
        JSCContext = JSContextWrapper(javaScriptContent: scriptContent)
        createWebView()
        JSCContext.invoke(payload: JSContextPayload(type: .callInitial, payload: ["webViewId": uid]))
    }
    
    private func createWebView() {
        routeStack.append(WoWMiniWebViewController(appId: appId, webViewId: uid))
        uid += 1
    }
    
    public func ready(pagePath: String) {
        pushWebView(pagePath: pagePath)
    }
    
    private func pushWebView(pagePath: String) {
        let miniProgramEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: self.appId)
        let payload = JSContextPayload(type: .callPushRouter, payload: ["webViewId": uid - 1, "pageId": pagePath])
        miniProgramEngine?.JSCContext.invoke(payload: payload)
        routeStack.last!.load(pagePath: pagePath)
    }
    
    public func getWebViewPage(with webViewId: Int) -> WoWMiniWebViewController {
        return routeStack[webViewId]
    }
    
    public func push(pagePath: String) {
        createWebView()
        rootViewController?.pushViewController(routeStack.last!, animated: true)
        pushWebView(pagePath: pagePath)
    }
    
    public func pop(deepLen: Int = 1) {
        let startIndex = routeStack.count - deepLen
        let endIndex = routeStack.count
        for index in (startIndex..<endIndex).reversed() {
            let webPage = routeStack.remove(at: index)
            PageLifeCycle.onUnload.load(appId: appId, webViewController: webPage)
            webPage.removeFromParent()
        }
        rootViewController?.popToViewController(routeStack.last!, animated: true)
        // 在 JSC 退出路由
    }
    
    public func launch() {
        launched = true
        let navigationController = UINavigationController(rootViewController: routeStack.first!)
        navigationController.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first!.rootViewController!.present(navigationController, animated: true, completion: nil)
        rootViewController = navigationController
    }
    
    public func close() {
        launched = false
        // 真正关闭的时候才将所有的 routerStack 清空
        rootViewController?.dismiss(animated: true, completion: nil)
    }
}
