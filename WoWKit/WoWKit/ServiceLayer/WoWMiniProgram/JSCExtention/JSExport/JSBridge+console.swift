//
//  JSBridge+console.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import WoWKitDependency

extension JSBridge {
    static func console(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        // 将数据传给 WebPageViewController
        let messages = option.payload as? [Any] ?? []
        let first = messages.first as? String ?? ""
        switch first {
        case "error":
            logger.error("📲JSCore->Native: \(messages)")
        case "warn":
            logger.warn("📲JSCore->Native: \(messages)")
        default:
            logger.info("📲JSCore->Native: \(messages)")
        }
        callback("")
    }
}
