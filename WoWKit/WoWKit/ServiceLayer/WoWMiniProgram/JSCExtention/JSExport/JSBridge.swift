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
//        switch self {
//        case .setData:
//            
//        }
    }
}





