//
//  WebViewJSBridge+lifeCycle.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation

enum WebViewLifeCycle: String {
    case ready = "ready"
}

extension WebViewInvokeNative {
    func lifeCycle(target: WoWMiniWebViewController, lifeHook: String) {
        let lifeCycle = WebViewLifeCycle(rawValue: lifeHook)
        switch lifeCycle {
        case .ready:
            target.ready()
        default:
            break
        }
    }
}
