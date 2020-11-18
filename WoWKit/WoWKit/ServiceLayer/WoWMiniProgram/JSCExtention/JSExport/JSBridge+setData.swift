//
//  JSBridge+setData.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import Foundation
import WoWKitDependency

extension JSBridge {
    static func setData(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        // 传递数据给 Mini Program 的渲染容器 WoWMiniWebViewController
        let miniProgramEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: option.appId)
        if let webViewId = option.webViewId,
        let mpwebPageViewController = miniProgramEngine?.getWebViewPage(with: webViewId) {
            let payload = option.payload as? [String: Any] ?? [:]
            let data = try! payload.toJSON()
            logger.info(data)
            mpwebPageViewController.setData(data: try! payload.toJSON())
            callback("")
        }
    }
}
