//
//  WoWRuntimeDownloader.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/12/1.
//

import Foundation
import WoWKitDependency
import ZipArchive

public class WoWRuntimeDownloader {
    public init() {}
     
    public func download(_ url: URL, tmpDir: String, dir: String, handler: @escaping (Bool) -> Void) {
        _ = WoWDownloader.shared.dowloadFile(with: URLRequest(url: url)) { (error, tmpUrl) in
            if error != nil {
                logger.error(error)
                handler(false)
                return
            }
            
            do {
                try SSZipArchive.unzipFile(atPath: tmpUrl!.path, toDestination: tmpDir, overwrite: true, password: nil)
            } catch {
                logger.error(error.localizedDescription)
                handler(false)
                return
            }
            
            var err: Error? = nil
            fs.unlink(file: dir, error: &err)
            fs.mkdir(path: dir, error: &err)
            // 构建 & 移动到正式目录
            guard let fileList = fs.readDir(path: tmpDir, recursive: true, error: &err) else {
                logger.error(err?.localizedDescription ?? "解析MPRuntime失败")
                handler(false)
                return
            }
          
            var buildError: Error? = nil
            for filePath in fileList {
                let fileNameIndex = filePath.index(filePath.startIndex, offsetBy: tmpDir.count)
                let fileName = filePath.suffix(from: fileNameIndex)
                fs.mv(at: filePath, to: dir.appending(fileName), error: &buildError)
            }
          
            if buildError != nil {
                logger.error(buildError)
                handler(false)
            }
          
            handler(true)
        }
    }
}
