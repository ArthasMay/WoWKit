//
//  WoWFileReader.swift
//  WoWKitDependency
//  WoWFileReader: 读取MP相关文件
//  Created by Silence on 2020/11/17.
//

import Foundation

class WoWFileReader {
    static let shared = WoWFileReader()
    private init() { }
    
    func readFileContent(appId: String, fileName: String, error: inout Error?) -> String {
        let name = fileName.hasPrefix("/") ? fileName : "/\(fileName)"
        let filePath = WoWMPConfig.miniProgramDir.appending(appId).appending(name)
        do {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        } catch let err {
            error = err
        }
        return ""
    }
}
