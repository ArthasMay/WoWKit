//
//  JSBridge.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import JavaScriptCore
import UIKit

protocol JSBridgeExports: JSExport {
    static func invoke(_ payload: String) -> Any?
}

class JSBridge: JSBridgeExports {
    class func invoke(_ payload: String) -> Any? {
        let invokeOption = JSInvokeNativeOption(JSONString: payload)
        return invokeOption?.invoke()
    }
}

extension InvokeNativeMethod {
    func load(options: JSInvokeNativeOption, _ callback: @escaping (Any?) -> Void) {
        switch self {
        case .setData:
            JSBridge.setData(option: options, callback: callback)
        case .launch:
            JSBridge.launch(option: options, callback: callback)
        case .console:
            JSBridge.console(option: options, callback: callback)
        case .navigateTo:
            JSBridge.navigateTo(option: options, callback: callback)
        case .setStorage:
            JSBridge.setStorage(option: options, callback: callback)
        case .getStorage:
            JSBridge.getStorage(option: options, callback: callback)
        default:
            break
        }
    }
}





