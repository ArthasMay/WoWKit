//
//  JSBridge+launch.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import ObjectMapper
import WoWKitDependency

class JSCLaunchPayload: Mappable {
    var url: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        url <- map["url"]
    }
}

extension JSBridge {
    static func launch(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        // 把数据传递给 webviewController
        let payload = JSCLaunchPayload(JSON: option.payload as? [String:Any] ?? [:])
        let mpEngineContext = WoWMPEngineContext.shared
        
        logger.info("launch")
        DispatchQueue(label: "com.miniprogram.wait.created").async {
            while (true) {
                let mpEngine = mpEngineContext.getMiniProgramEngine(appId: option.appId)
                if (mpEngine != nil) {
                    DispatchQueue.main.async {
                        mpEngine?.ready(pagePath: payload!.url!)
                    }
                    break
                }
            }
            
        }
        callback("")
    }
}
