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
        JSCContext.invoke(payload: JSContextPayload(type: .callInitial, payload: ["webviewId": uid]))
    }
    
    private func createWebView() {
        routeStack.append(WoWMiniWebViewController(appId: appId, webviewId: uid))
        uid += 1
    }
    
    private func pushWebView(pagePath: String) {
        let miniProgramEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: self.appId)
        let payload = JSContextPayload(type: .callPushRouter, payload: ["webviewId": uid - 1, "pageId": pagePath])
        miniProgramEngine?.JSCContext.invoke(payload: payload)
//        routeStack.last!.
    }
}
