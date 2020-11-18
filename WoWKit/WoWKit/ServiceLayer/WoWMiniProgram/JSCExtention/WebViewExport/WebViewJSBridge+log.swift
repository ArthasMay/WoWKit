//
//  WebViewJSBridge+log.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import WoWKitDependency

extension WebViewInvokeNative {
    func log(payload: Any?) {
        logger.info(payload as? [String] ?? [])
    }
}
