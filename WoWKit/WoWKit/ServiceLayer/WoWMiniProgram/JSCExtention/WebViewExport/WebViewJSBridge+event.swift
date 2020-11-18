//
//  WebViewJSBridge+event.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import ObjectMapper

class WVJSEventPayload: Mappable {
    var method: String?
    var payload: Any?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        method <- map["method"]
        payload <- map["payload"]
    }
}

extension WebViewInvokeNative {
    func event(target: WoWMiniWebViewController, option: WebViewInvokeNativeOption) {
        let eventPayload = WVJSEventPayload(JSON: option.payload as? [String: Any] ?? [:])
        let mpEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: target.appId)
        let payload = [
            "lifeCycle": eventPayload?.method,
            "payload": eventPayload?.payload,
            "webViewId": target.webViewId
        ]
        let jscPayload = JSContextPayload(type: .callPageLifeCycle, payload: payload as [String: Any])
        mpEngine?.JSCContext.invoke(payload: jscPayload)
    }
}
