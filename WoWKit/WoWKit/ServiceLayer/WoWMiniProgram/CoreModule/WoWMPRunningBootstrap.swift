//
//  WoWMPRunningBootstrap.swift
//  WoW-Example
//  小程序 bootstrap
//  Created by Silence on 2020/11/5.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import WoWKitDependency
import ZipArchive

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
    
    public init() {}
    
    /// 下载 MiniProgram 的资源代码
    /// - Parameters:
    ///   - mppURL: MiniProgramPackageURL  小程序资源包地址
    ///   - callbackClosure: 下载完成后的 callback
    private func download(_ mppURL: URL, callback callbackClosure: @escaping (_ error: Error?, _ mppURL: URL?) -> Void) {
        let fileName = UUID().uuidString.appending(".zip")
        _ = WoWDownloader.shared.dowloadFile(with: URLRequest(url: mppURL), with: fileName) { (error, tempURL) in
            if error != nil {
                callbackClosure(error, nil)
                return
            }
            callbackClosure(nil, tempURL)
        }
    }
    
    /// 运行小程序
    /// - Parameters:
    ///   - appId: 小程序 id
    ///   - mppURL: MiniProgramPackageURL  小程序资源包地址
    public func run(_ appId: String, _ mppURL: URL) {
        self.appId = appId
     
        // 存在资源文件，直接启动
        if fs.exists(file: mpDir) {
            WoWMPEngineContext.shared.launchApp(appId: appId)
            return
        }
        
        // 本地没有资源包 下载 -> 解压
        download(mppURL) { (err, localURL) in
            if err != nil {
                logger.error(err)
                return
            }
          
            // 解压小程序
            do {
                try SSZipArchive.unzipFile(atPath: localURL!.path, toDestination: WoWMPConfig.mpTempDir, overwrite: true, password: nil)
            } catch {
                logger.error(error.localizedDescription)
                return
            }
            
            var err: Error? = nil
            // 清空原来的小程序
            fs.unlink(file: self.mpDir, error: &err)
            fs.mkdir(path: self.mpDir, error: &err)
            // 构建 & 移动到正式目录
            guard let fileList = fs.readDir(path: self.tempMPDir, recursive: true, error: &err) else {
                logger.error(err?.localizedDescription ?? "解析小程序失败")
                return
            }
            
            var buildError: Error? = nil
            for filePath in fileList {
                let fileNameIndex = filePath.index(filePath.startIndex, offsetBy: self.tempMPDir.count)
                let fileName = filePath.suffix(from: fileNameIndex)
                if filePath.hasSuffix(".js") {
                    // 将js文件移动到正式目录下
                    fs.mv(at: filePath, to: self.mpDir.appending(fileName), error: &buildError)
                    continue
                }
                
                // 处理html文件, 处理rpx
                var htmlFileContent = try! String(contentsOfFile: filePath)
                htmlFileContent = htmlFileContent.replacingOccurrences(of: "__SCALE__", with: String(Float(1) / Float(UIScreen.main.scale)))
                htmlFileContent = htmlFileContent.replacingOccurrences(of: "__FONT_SIZE__", with: String(Float(100 / 2 * UIScreen.main.scale)))
                fs.write(file: self.mpDir.appending(fileName), data: htmlFileContent.data(using: .utf8)!, error: &buildError)
            }
            
            if buildError != nil {
                logger.error(buildError)
            }
            
            // 运行小程序
            WoWMPEngineContext.shared.launchApp(appId: appId)
        }
    }
}
