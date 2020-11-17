//
//  WoWFileUtils.swift
//  WoWKit
//
//  Created by Silence on 2020/11/5.
//

import Foundation

class WoWFileUtils {
    static func moveFile(from url: URL,
                         toDirectory: String?,
                         with name: String) -> (Bool, Error?, URL?) {
        var newUrl: URL
        if let directory = toDirectory {
            let directoryCreationResult = self.createDirectoryIfNotExists(with: directory)
            guard directoryCreationResult.0 else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl =
                self.cacheDirectoryPath()
                .appendingPathComponent(directory)
                .appendingPathComponent(name)
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return (true, nil, newUrl)
        } catch  {
            return (false, error, nil)
        }
    }
    
    static func cacheDirectoryPath() -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: cachePath)
    }
    
    static func createDirectoryIfNotExists(with name: String) -> (Bool, Error?) {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
}

