//
//  WoWMPEngineContext.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/16.
//

import Foundation
import WoWKitDependency

class WoWMPEngineContext {
    static let shared = WoWMPEngineContext()
    private init() {
        logger.info("【WoWMiniProgram】: WoWMPEngineContext init")
    }
    private var ref: [String: WoWMPEngine] = [:]
    private var lock = false
    
    func getMiniProgramEngine(appId: String?) -> WoWMPEngine? {
        guard let appId = appId else {
            return nil
        }
        if lock {
            return nil
        }
        return self.ref[appId]
    }
    
    func launchApp(appId: String) {
        logger.info("【WoWMPEngineContext】: 当前打开的MiniProgram \(appId)")
        var miniprogram: WoWMPEngine? = ref[appId]
        if miniprogram == nil {
            miniprogram = WoWMPEngine(appId: appId)
        }
        
        // TODO: 1.运行的小程序超过最大设置值, LRU淘汰 2.内存收到警告，清除后台小程序
        lock = true
        ref[appId] = miniprogram
        lock = false
        miniprogram?.launch()
    }
}

