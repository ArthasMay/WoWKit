//
//  WoWMPRunningBootstrap.swift
//  WoW-Example
//  小程序 bootstrap
//  Created by Silence on 2020/11/5.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

public class WoWMPRunningBootstrap {
    // AppId 作为目录
    var appId = "mock_appid"
    
    // MiniProgram 解压后临时存放的文件夹目录
    var tempMPDir: String {
        return WoWMPConfig.mpTempDir.appending(appId)
    }
    
    // MiniProgram 下载存放目录
    var mpDir: String {
        return WoWMPConfig.miniProgramDir.appending(appId)
    }
    
    /// 下载 MiniProgram 的资源代码
    /// - Parameters:
    ///   - mppURL: MiniProgramPackageURL  小程序资源包地址
    ///   - callbackClosure: 下载完成后的 callback
    private func download(_ mppURL: URL, callback callbackClosure: @escaping (_ , err: Error?, _ mppLocalURL: URL?) -> Void) {
        
    }
    
    public func run(_ appId: String, _ mppURL: URL) {
        self.appId = appId
        
        // 校验资源包的
        
    }
}
