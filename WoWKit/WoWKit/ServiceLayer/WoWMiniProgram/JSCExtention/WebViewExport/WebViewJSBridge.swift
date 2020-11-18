//
//  WebViewJSBridge.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import WoWKitDependency

extension WebViewInvokeNative {
    func load(target: WoWMiniWebViewController, options: WebViewInvokeNativeOption) {
        switch self {
        case .lifeCycle:
            self.lifeCycle(target: target, lifeHook: options.payload as? String ?? "")
        case .log:
            self.log(payload: options.payload)
        case .event:
            self.event(target: target, option: options)
        }
    }
}
