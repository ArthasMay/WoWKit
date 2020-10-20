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
    static let `default`: WoWFastKV! = {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        path = path + "/default.fkv"
        return WoWFastKV(withFile: path, initialMemorySize: WoWFastDefaultInitialMMSize)
    }()
    
    public var headerInfo: String!
    
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
    @discardableResult
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
        
        headerInfo = "Mark: \(mark!)\n"
        
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
//            print(version!)
            headerInfo = headerInfo + "Version: \(version!)\n"
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
        headerInfo = headerInfo + "DataLength: \(dataLength)"
        
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
    
    @discardableResult
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
    public func bool(for key: String) -> Bool? {
        var val: NSNumber?
        if let kv = _item(for: key) {
            val = _numberValue(for: kv)
            if val == nil {
                if kv.valueType == .isString, let numString = kv.stringValue {
                    return (numString as NSString).boolValue
                }
            }
        }
        return val?.boolValue
    }
    
    public func integer(for key: String) -> Int? {
        var val: NSNumber?
        if let kv = _item(for: key) {
            val = _numberValue(for: kv)
            if val == nil {
                if kv.valueType == .isString, let numString = kv.stringValue {
                    return Int(numString)
                }
            }
        }
        return val?.intValue
    }
    
    public func float(for key: String) -> Float? {
        var val: NSNumber?
        if let kv = _item(for: key) {
            val = _numberValue(for: kv)
            if val == nil {
                if kv.valueType == .isString, let numString = kv.stringValue {
                    return Float(numString)
                }
            }
        }
        return val?.floatValue
    }
    
    
    public func double(for key: String) -> Double? {
        var val: NSNumber?
        if let kv = _item(for: key) {
            val = _numberValue(for: kv)
            if val == nil {
                if kv.valueType == .isString, let numString = kv.stringValue {
                    return Double(numString) ?? 0
                }
            }
        }
        return val?.doubleValue ?? 0
    }
    
    public func string(for key: String) -> String? {
        return _item(for: key)?.stringValue
    }
    
    public func object<C: NSObject>(of cls: C.Type, for key: String) -> AnyObject? where C: NSCoding {
        guard let kv = _item(for: key),
              let octype = _objcType(for: kv)
        else {
            return nil
        }
        
        if CASE_CLASS(cls: cls, type: NSNumber.self) {
            return _numberValue(for: kv)
        }
        
        if CASE_CLASS(cls: cls, type: NSString.self) {
            return kv.stringValue as NSString?
        }

        if CASE_CLASS(cls: cls, type: NSData.self) {
            if kv.valueType == .isData {
                return kv.binaryValue as AnyObject
            }
            return nil
        }
        
        if CASE_CLASS(cls: cls, type: NSDate.self) {
            if CASE_CLASS(cls: octype, type: NSDate.self) {
                let val = _unarchiveValue(for: NSDate.self, from: kv)
                if val == nil {
                    if let numVal = _numberValue(for: kv) {
                        return NSDate(timeIntervalSince1970: numVal.doubleValue)
                    }
                    return val
                }
            }
            return nil
        }
        
        if CASE_CLASS(cls: cls, type: NSURL.self) {
            if CASE_CLASS(cls: octype, type: NSURL.self) {
                let val = _unarchiveValue(for: NSDate.self, from: kv)
                if val == nil && kv.valueType == .isString && kv.stringValue != nil {
                    return NSURL(string: kv.stringValue!)
                }
                return val
            }
            return nil
        }
        
        // 暂时不支持自定义NSCoding类型吧
        return nil
    }
    
    public func setBool(val: Bool, for key: String) {
        let kv = WoWFKVPair(with: .isBool, objcType: WoWFastKVObjcClassNameNSNumber, key: key, version: WoWFastKVVersion)
        kv.boolValue = val
        append(kv)
    }
    
    public func setInteger(val: Int, for key: String) {
        let kv = WoWFKVPair(with: .isNil, objcType: WoWFastKVObjcClassNameNSNumber, key: key, version: WoWFastKVVersion)
        if abs(val) > Int32.max {
            kv.int64Value = Int64(val)
            kv.valueType = .isInt64
        } else {
            kv.int32Value = Int32(val)
            kv.valueType = .isInt32
        }
        append(kv)
    }
    
    public func setFloat(val: Int, for key: String) {
        let kv = WoWFKVPair(with: .isFloat, objcType: WoWFastKVObjcClassNameNSNumber, key: key, version: WoWFastKVVersion)
        append(kv)
    }
    
    public func setDouble(val: Int, for key: String) {
        let kv = WoWFKVPair(with: .isDouble, objcType: WoWFastKVObjcClassNameNSNumber, key: key, version: WoWFastKVVersion)
        append(kv)
    }
    
//    public func setObject<O: NSObject>(obj: O?, for key: String) {
//        guard let tObj = obj else {
//            let kv = WoWFKVPair()
//            kv.version = WoWFastKVVersion
//            kv.valueType = .isNil
//            kv.key = key
//            append(kv)
//            return
//        }
//
//        let kv = WoWFKVPair()
//        kv.version = WoWFastKVVersion
//        kv.key = key
//        kv.objcType = NSStringFromClass(O.Type as! AnyClass)
//    }
    
    public func removeObject(for key: String) {
        let kv = WoWFKVPair()
        kv.version = WoWFastKVVersion
        kv.valueType = .isRemoved
        kv.key = key
        self.append(kv)
    }
    
    public func removeAllKeys() {
        pthread_mutex_lock(&mutex)
        dict.removeAll()
        mapWithSize(initialMMSize)
        resetHeaderWithContentSize(dataLength: 0)
        pthread_mutex_unlock(&mutex)
    }
    
    public func cleanUp() {
        pthread_mutex_lock(&mutex)
        if mmPtr != nil {
            munmap(mmPtr, curSize)
        }
        if fd > 0 {
            ftruncate(fd, off_t(curSize))
            close(fd)
        }
        mmSize = 0
        curSize = 0
        dict.removeAll()
        try? FileManager.default.removeItem(atPath: path)
        if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
            pthread_mutex_unlock(&mutex)
            open(file: path)
        }
        pthread_mutex_unlock(&mutex)
    }
    
    private func _item(for key: String) -> WoWFKVPair? {
        pthread_mutex_lock(&mutex)
        let kv = dict[key]
        pthread_mutex_unlock(&mutex)
        return kv
    }
        
    private func _objcType<C: NSObject>(for kv: WoWFKVPair) -> C.Type? {
        if let objcType = kv.objcType {
            return NSClassFromString(objcType) as? C.Type
        }
        return nil
    }
    
    private func _numberValue(for kv: WoWFKVPair) -> NSNumber? {
        switch kv.valueType {
        case .isBool: return NSNumber(booleanLiteral: kv.boolValue ?? false)
        case .isInt32: return NSNumber(integerLiteral: Int(kv.int32Value ?? 0))
        case .isInt64: return NSNumber(integerLiteral: Int(kv.int64Value ?? 0))
        case .isFloat: return NSNumber(floatLiteral: Double(kv.floatValue ?? 0))
        case .isDouble: return NSNumber(floatLiteral: kv.doubleValue ?? 0)
        case .isData:
            return self._unarchiveValue(for: NSNumber.self, from: kv)
        default:
            return nil
        }
    }
    
    private func _unarchiveValue<T>(for cls: T.Type, from kvItem: WoWFKVPair) -> T? where T: NSObject, T: NSCoding {
        if kvItem.valueType == .isData, let data = kvItem.binaryValue {
            if let val = try? NSKeyedUnarchiver.unarchivedObject(ofClass: cls, from: data) {
                return val
            }
            return nil
        }
        return nil
    }
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

fileprivate func CASE_CLASS<C, T>(cls: C.Type, type: T.Type) -> Bool where C: NSObject, T: NSObject {
    return cls == type || cls.isSubclass(of: type)
}

