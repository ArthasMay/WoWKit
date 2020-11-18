//
//  PageLifeCycle+hook.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import Foundation
import WoWKitDependency

extension PageLifeCycle {
    func load(appId: String, webViewController: WoWMiniWebViewController) {
        guard let miniProgramEngine = getMiniProgramEngine(appId: appId)  else {
            logger.info("【WoWMiniProgram】: MiniProgramEngine 已经销毁")
            return
        }
        switch self {
        case .onLoad:
            callOnLoad(miniProgramEngine: miniProgramEngine, webViewController: webViewController)
        case .onReady:
            callOnReady(miniProgramEngine: miniProgramEngine, webViewController: webViewController)
        case .onAppear:
            callOnAppear(miniProgramEngine: miniProgramEngine, webViewController: webViewController)
        case .onDisappear:
            callOnDisappear(miniProgramEngine: miniProgramEngine, webViewController: webViewController)
        case .onUnload:
            callOnUnload(miniProgramEngine: miniProgramEngine, webViewController: webViewController)
        }
    }
    
    private func getMiniProgramEngine(appId: String) -> WoWMPEngine? {
        return WoWMPEngineContext.shared.getMiniProgramEngine(appId: appId)
    }
    
    private func createPayload(_ webViewController: WoWMiniWebViewController, _ lifeCycle: String, _ payload: Any? = nil) -> JSContextPayload {
        return .init(type: .callPageLifeCycle, payload: ["lifeCycle": lifeCycle, "webViewId": webViewController.webViewId, "payload": payload ?? ""])
    }
    
    private func callOnLoad(miniProgramEngine: WoWMPEngine, webViewController: WoWMiniWebViewController) {
        miniProgramEngine.JSCContext.invoke(payload: createPayload(webViewController, "onLoad", webViewController.queryOption))
    }
    
    private func callOnUnload(miniProgramEngine: WoWMPEngine, webViewController: WoWMiniWebViewController) {
        miniProgramEngine.JSCContext.invoke(payload: createPayload(webViewController, "onUnload"))
    }
    
    private func callOnAppear(miniProgramEngine: WoWMPEngine, webViewController: WoWMiniWebViewController) {
        miniProgramEngine.JSCContext.invoke(payload: createPayload(webViewController, "onAppear"))
    }
    
    private func callOnReady(miniProgramEngine: WoWMPEngine, webViewController: WoWMiniWebViewController) {
        miniProgramEngine.JSCContext.invoke(payload: createPayload(webViewController, "onReady"))
    }
    
    private func callOnDisappear(miniProgramEngine: WoWMPEngine, webViewController: WoWMiniWebViewController) {
        miniProgramEngine.JSCContext.invoke(payload: createPayload(webViewController, "onDisappear"))
    }
}
