//
//  JSContextWrapper.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/16.
//

import Foundation
import JavaScriptCore
import WoWKitDependency

class JSContextPayload {
    let type: InvokeJSCoreType
    let payload: [String: Any]
    
    init(type: InvokeJSCoreType, payload: [String: Any]) {
        self.type = type
        self.payload = payload
    }
}

class JSContextWrapper {
    let context: JSContext
    // 这边需要理解下call函数和this的指向问题
    let prefixScript = """
        var module = { exports: {} };
        function __vm(global) {
    """
    let suffixScript = "}; __vm.call(module.exports, module.exports)"
    
    init(javaScriptContent: String) {
        let context: JSContext = JSContext()
        context.exceptionHandler = { context, exception in
            let sourcemap = exception?.toDictionary()
            logger.error("JS Error: \(exception?.toString() ?? "No Error."):\(String(describing: sourcemap?["line"] ?? "")):\(String(describing: sourcemap?["column"] ?? ""))")
        }
        context.evaluateScript("console.log('Hello, WoWMiniProgram!')")
        context.setObject(JSBridge.self, forKeyedSubscript: "__JSB" as NSCopying & NSObjectProtocol)
        let script = "\(prefixScript)\(javaScriptContent)\(suffixScript)"
        context.evaluateScript(script)
        self.context = context
    }
    
    func invoke(payload: JSContextPayload) {
        let payloadJSON = try! payload.payload.toJSON()
        let scriptContent = "module.exports.__polyfill__.nativeInvoke({ type: \(payload.type.rawValue), payload: \(payloadJSON) })"
        logger.info("execscript: \(scriptContent)")
        self.context.evaluateScript(scriptContent)
    }
}
