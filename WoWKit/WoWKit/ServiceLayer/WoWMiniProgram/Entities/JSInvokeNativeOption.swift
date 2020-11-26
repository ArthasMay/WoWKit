//
//  JSInvokeNativeOption.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import Foundation
import ObjectMapper

class JSInvokeNativeOption: Mappable {
    var sessionId: String?
    var appId: String?
    var isSync: Bool?
    var method: InvokeNativeMethod?
    var webViewId: Int?
    var payload: Any?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        sessionId <- map["sessionId"]
        isSync <- map["sync"]
        method <- map["method"]
        webViewId <- map["webviewId"]
        payload <- map["payload"]
        appId <- map["appId"]
    }
    
    func invoke() -> Any? {
        var res: Any? = nil
        var callbacked = false
        method?.load(options: self, { (response) in
            res = response
            callbacked = true
        })
        
        if !(isSync ?? false) {
            return nil
        }
        
        while !callbacked {
            // no get response
        }
        return res
    }
}
