//
//  WebViewInvokeNativeOption.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import ObjectMapper

class WebViewInvokeNativeOption: Mappable {
    var type: WebViewInvokeNative?
    var payload: Any?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        payload <- map["payload"]
    }
    
    func invoke(target: WoWMiniWebViewController) {
        type?.load(target: target, options: self)
    }
}
