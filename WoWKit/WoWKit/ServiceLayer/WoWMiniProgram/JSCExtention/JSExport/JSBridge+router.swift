//
//  JSBridge+router.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation
import WoWKitDependency

extension JSBridge {
    static func navigateTo(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        let prefix = "pages"
        guard let payload = option.payload as? [[String: Any]] else {
            logger.warn("【WoWMP】: 参数错误")
            return
        }
        guard let url = payload.first?["url"] else {
            logger.warn("【WoWMP】: 缺少 url 参数")
            return
        }
        
        let mpEngine = WoWMPEngineContext.shared.getMiniProgramEngine(appId: option.appId)
        mpEngine?.push(pagePath: "\(prefix)\(url)")
        callback("")
    }
}
