//
//  JSBridge+setData.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import Foundation

extension JSBridge {
    static func setData(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        // 传递数据给 Mini Program 的渲染容器 WoWMiniWebViewController
        let miniProgramEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: option.appId)
        let webviewPage = miniProgramEngine.
    }
}
