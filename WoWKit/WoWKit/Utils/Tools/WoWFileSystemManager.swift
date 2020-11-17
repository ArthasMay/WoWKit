//
//  FileSystemManager.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/16.
//

import Foundation

/// 文件管理系统
public let fs = FileSystemManager.shared

public final class FileSystemManager {
    static let shared = FileSystemManager()
    private let fileSystem = FileManager.default
    private init() {}
    
    /// 写入数据到指定路径文件
    /// - Parameters:
    ///   - file: 文件路径
    ///   - data: 数据
    ///   - error: 异常错误
    public func write(file: String, data: Data, error: inout Error?) {
        mkdir(path: getDirectory(file: file), error: &error)
        if error != nil { return }
        do {
            try data.write(to: URL(fileURLWithPath: file))
        } catch let err {
            error = err
        }
    }
    
    /// 读取指定文件的内容，返回文件data
    /// - Parameters:
    ///   - file: 文件路径
    ///   - error: 异常错误
    /// - Returns: 文件数据data
    public func read(file: String, error: inout Error?) ->Data? {
        do {
            return try Data(contentsOf: URL(fileURLWithPath: file))
        } catch let err {
            error = err
            return nil
        }
    }
    
    /// 创建目录
    /// - Parameters:
    ///   - path: 目录地址
    ///   - error: 异常错误
    public func mkdir(path: String, error: inout Error?) {
        guard !fileSystem.fileExists(atPath: path) else {
            return
        }
        do {
            try fileSystem.createDirectory(
                at: URL(fileURLWithPath: path),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let err {
            error = err
        }
    }
    
    /// 读取路径下的文件
    /// - Parameters:
    ///   - path: 文件夹路径
    ///   - error: 异常错误
    /// - Returns: 文件夹下的文件，以路径数组的形式返回
    public func readDir(path: String, error: inout Error?) -> [String]? {
        do {
            return try fileSystem.contentsOfDirectory(atPath: path)
        } catch let err {
            error = err
            return nil
        }
    }
    
    public func mv(at atPath: String, to toPath: String, error: inout Error?) {
        let toPathDir = getDirectory(file: toPath)
        mkdir(path: toPathDir, error: &error)
        do {
            try fileSystem.moveItem(at: URL(fileURLWithPath: atPath), to: URL(fileURLWithPath: toPath))
        } catch let err {
            error = err
        }
    }
    
    public func unlink(file: String, error: inout Error?) {
        do {
            try fileSystem.removeItem(at: URL(fileURLWithPath: file))
        } catch let err {
            error = err
        }
    }
    
    public func readDir(path: String, recursive: Bool, error: inout Error?) -> [String]? {
        do {
            if (recursive) {
                let url = URL(fileURLWithPath: path)
                var files = [String]()
                if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                            if fileAttributes.isRegularFile! {
                                files.append(fileURL.path)
                            }
                        } catch { print(error, fileURL) }
                    }
                    return files
                }
            }
            return try fileSystem.contentsOfDirectory(atPath: path)
        } catch let err {
            error = err
            return nil
        }
    }
    
    /// 检验文件是否存在
    /// - Parameter file: 文件路径
    /// - Returns: 校验结果
    public func exists(file: String) -> Bool {
        return fileSystem.fileExists(atPath: file)
    }
    
    /// 获取文件所在文件夹路径：abc/abc.p => abc/
    /// - Parameter file: 文件路径
    /// - Returns: 所在文件夹路径
    public func getDirectory(file: String) -> String {
        let nsfile = NSString(string: file)
        return nsfile.deletingLastPathComponent
    }
    
    /// 检验文件所在目录是否存在
    /// - Parameter file: 文件路径
    /// - Returns: 检验结果
    public func directoryExists(file: String) -> Bool {
        let directory = getDirectory(file: file)
        return exists(file: directory)
    }
}
