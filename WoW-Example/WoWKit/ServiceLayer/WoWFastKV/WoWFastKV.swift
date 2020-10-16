//
//  WoWMMKV.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/12.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

@objc
public enum WoWFastKVMemoryStrategy: UInt {
    case `default` = 0
    case strategy1
}

public final class WoWFastKV {
    static let shared: WoWFastKV = {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        path = path + "/default.fkv"
        return WoWFastKV(withFile: path, initialMemorySize: WoWFastDefaultInitialMMSize)
    }()
    
    private var fd: Int32 = 0
    private var mmPtr: UnsafeMutableRawPointer!
    private var mmSize: size_t = 0
    private var curSize: size_t = 0
    private var initialMMSize: size_t = 0
    private var path: String!
    private var memStrategy: WoWFastKVMemoryStrategy = .default
    
    private var dict = [String: WoWFKVPair]()
    private var mutex = pthread_mutex_t()

    // MARK: - Initializer
    public init!(withFile path: String,
                memStrategy: WoWFastKVMemoryStrategy = .default,
                initialMemorySize: size_t) {
        guard let _ = try? FileManager.default.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil) else {
            return nil
        }
        self.path = path
        self.memStrategy = memStrategy
        self.initialMMSize = initialMemorySize
        
        pthread_mutex_init(&mutex, nil)
        
        if self.open(file: path) == false {
            return nil
        }
    }
    
    // MARK: - Private methods
    private func open(file: String) -> Bool {
        pthread_mutex_lock(&mutex)
        
        // https://fossies.org/linux/swift-swift/stdlib/public/Platform/Platform.swift
        // Linux C APi: swift 应该是进行方法绑定（编译层），提供了Swift的Api
        fd = Darwin.open(file, O_RDWR | O_CREAT, mode_t(0o000666))
        if fd == 0 {
            pthread_mutex_unlock(&mutex)
            // TODO:
            assert(false, "[WoWFastKV] failed to open file: " + file)
            return false
        }
        
        var statInfo = stat()
        if fstat(fd, &statInfo) != 0 {
            pthread_mutex_unlock(&mutex)
            // TODO:
            assert(false, "[WoWFastKV] failed to read file stat: " + file)
            return false
        }
        
        if reallocMMSize(with: size_t(statInfo.st_size)) == false {
            pthread_mutex_unlock(&mutex)
            return false
        }
        
        if (statInfo.st_size == 0) {
            self.resetHeaderWithContentSize(dataLength: 0)
            curSize = 18
            pthread_mutex_unlock(&mutex)
            return true
        }
        
        // read mark string
        var ptr: UnsafeMutableRawPointer! = mmPtr
        let data = Data(bytes: ptr, count: 18)
        let bytes = [UInt8](data)
        let mark = String(bytes: bytes[0..<6], encoding: .utf8)
        if mark != WoWFastMarkString {
            pthread_mutex_unlock(&mutex)
            assert(false, "[WoWFastKV] Not WoWFastKV file: " + file)
            return false
        }
        
        // read version
        ptr = ptr.advanced(by: 6)
        let versionPtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + 6
        }
        let version = versionPtr?.withMemoryRebound(to: __uint32_t.self, capacity: MemoryLayout<__uint32_t>.size) {
            $0.pointee
        }
        if version != nil {
            print(version!)
        }
        
        // read data length
        let dataLenPtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + 10
        }
        let dataLen = dataLenPtr?.withMemoryRebound(to: __uint64_t.self, capacity: MemoryLayout<__uint64_t>.size) {
            $0.pointee
        }
        guard let dataLength = dataLen else {
            pthread_mutex_unlock(&mutex)
            assert(false, "[WoWFastKV] Illegal file size")
            return false
        }
        if dataLength + __uint64_t(WoWFastKVHeaderSize) > statInfo.st_size {
            pthread_mutex_unlock(&mutex)
            assert(false, "[WoWFastKV] Illegal file size")
            return false
        }
        
        // read data
        ptr = ptr.advanced(by: 18)
        let valLength = min(dataLength, (__uint64_t)(statInfo.st_size) - (__uint64_t)(WoWFastKVHeaderSize))
        let valData = Data(bytes: ptr, count: Int(valLength))
        
        guard let kvList = try? WoWFKVPairList.parse(from: valData) as? WoWFKVPairList else {
            pthread_mutex_unlock(&mutex)
            assert(false, "[WoWFastKV] KVData parse to list failed")
            return false
        }
        
        kvList.items.forEach {
            if $0.key != nil && $0.valueType != .isRemoved {
                dict[$0.key!] = $0
            } else if $0.valueType == .isRemoved && $0.key != nil{
                dict.removeValue(forKey: $0.key!)
            }
        }
        self.reallocWithExtraSize(0)
        pthread_mutex_unlock(&mutex);
        return true
    }
    
    private func resetHeaderWithContentSize(dataLength: __uint64_t) {
        var ptr: UnsafeMutableRawPointer = mmPtr
        memcpy(ptr, WoWFastMarkString, 6)
        ptr = ptr.advanced(by: 6)
        let fastKV_version_ptr = UnsafeMutablePointer<__uint32_t>.allocate(capacity: 1)
        fastKV_version_ptr.pointee = WoWFastKVVersion
        memcpy(ptr, fastKV_version_ptr, 4)
        ptr = ptr.advanced(by: 4)
        let dataLen_ptr = UnsafeMutablePointer<__uint64_t>.allocate(capacity: 1)
        dataLen_ptr.pointee = dataLength
        memcpy(ptr, dataLen_ptr, 8)
    }
    
    private func mapWithSize(_ mapSize: size_t) -> Bool {
        let mmsize = max(mapSize, initialMMSize)
        mmPtr = mmap(nil, mmsize,  PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fd, 0)
        if mmPtr == MAP_FAILED {
            assert(false, "[WoWFastKV] create mmap failed: \(errno)")
            return false
        }
        // 修改文件大小
        ftruncate(fd, off_t(mmsize))
        self.mmSize = mmsize
        return true
    }
    
    func append(_ item: WoWFKVPair) {
        pthread_mutex_lock(&mutex)
        var isUpdated = false
        if let oldItem = dict[item.key!] {
            isUpdated = true
            if oldItem == item {
                pthread_mutex_unlock(&mutex)
                return
            }
        }
        
        if item.valueType != .isRemoved {
            dict[item.key!] = item
        } else {
            dict.removeValue(forKey: item.key!)
        }
        
        var data = Data()
        data.append(item.representationData())
        data.append(WoWFastKVSeperatorString.data(using: .utf8)!)
        
        if data.count + curSize > mmSize {
            self.reallocWithExtraSize(data.count, updated: isUpdated)
        } else {
            memcpy(mmPtr.advanced(by: curSize), [UInt8](data), data.count)
            curSize = curSize + data.count
            
            let dataLength = __uint64_t(curSize - WoWFastKVHeaderSize)
            let dataLen_ptr = UnsafeMutablePointer<__uint64_t>.allocate(capacity: 1)
            dataLen_ptr.pointee = dataLength
            memcpy(mmPtr.advanced(by: 10), dataLen_ptr, 8)
        }
        pthread_mutex_unlock(&mutex)
    }
    
    private func reallocWithExtraSize(_ size: size_t) {
        self.reallocWithExtraSize(size, updated: false)
    }
    
    private func reallocWithExtraSize(_ size: size_t, updated: Bool) {
        let kvList = WoWFKVPairList()
        dict.forEach { (key, value) in
            if value.valueType != .isRemoved {
                kvList.items.append(value)
            }
        }
        let data = kvList.representationData()
        let dataLength = data.count
        
        let totalSize = dataLength + WoWFastKVHeaderSize
        let neededSize = updated ? self._fkvAllocationSize(with: (totalSize + size)) : (totalSize + size)
        if neededSize > mmSize || (updated && self._fkvAllocationSize(with: neededSize) > mmSize) {
            self.reallocWithExtraSize(neededSize)
            self.resetHeaderWithContentSize(dataLength: 0)
        }
        let ptr: UnsafeMutableRawPointer = mmPtr
        memcpy(ptr.advanced(by: WoWFastKVHeaderSize), [UInt8](data), dataLength)
        let dataLen_ptr = UnsafeMutablePointer<__uint64_t>.allocate(capacity: 1)
        dataLen_ptr.pointee = __uint64_t(dataLength)
        memcpy(ptr.advanced(by: 10), dataLen_ptr, 8)
        curSize = dataLength + WoWFastKVHeaderSize
    }
    
    private func reallocMMSize(with neededSize: size_t) -> Bool {
        var allocationSize = neededSize
        allocationSize = _fkvAllocationSize(with: neededSize)
        return mapWithSize(allocationSize)
    }
    
    private func _fkvAllocationSize(with neededSize: size_t) -> size_t {
        var allocationSize: size_t = neededSize
        switch memStrategy {
        case .default:
            allocationSize = FastKVStrategyDefaultAlloctionSize(with: neededSize)
        case .strategy1:
            allocationSize = FastKVStrategy1AllocationSize(with: neededSize)
        }
        return allocationSize
    }
    
    // MARK: - Public Methods(API)
    
}

fileprivate func FastKVStrategyDefaultAlloctionSize(with neededSize: size_t) -> size_t {
    var allocationSize: size_t = 1
    while allocationSize <= neededSize {
        allocationSize = allocationSize * 2
    }
    return allocationSize
}

fileprivate func FastKVStrategy1AllocationSize(with neededSize: size_t) -> size_t {
    let allocationSize = (neededSize >> 3) + (neededSize < 9 ? 3 : 6)
    return allocationSize + neededSize
}


