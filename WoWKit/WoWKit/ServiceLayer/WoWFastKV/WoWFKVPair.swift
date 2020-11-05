//
//  WoWFkvPair.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/12.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation
import WoWKitDependency

public enum WoWFKVPairType: UInt {
    case isRemoved = 0
    case isNil
    case isBool
    case isInt32
    case isInt64
    case isFloat
    case isDouble
    case isString
    case isData
}

protocol WoWFKVCoding {
    static func parse(from data: Data) throws -> Any?
    func representationData() -> Data
}

public final class WoWFKVPair {
    public var valueType: WoWFKVPairType = .isNil
    public var objcType: String?
    public var key: String?
    public var boolValue: Bool?
    public var int32Value: Int32?
    public var int64Value: Int64?
    public var floatValue: Float?
    public var doubleValue: Double?
    public var stringValue: String?
    public var binaryValue: Data?
    public var version: UInt32?
    
    public init(with valueType: WoWFKVPairType,
                objcType: String,
                key: String,
                version: UInt32) {
        self.valueType = valueType
        self.objcType = objcType
        self.key = key
        self.version = version
    }
    
    init() {}
}

extension WoWFKVPair: WoWFKVCoding {
    static func parse(from data: Data) throws -> Any? {
        if data.count == 0 {
            return nil
        }

        // CRC check
        let crc = data.subdata(in: 0..<data.count-2).fkv_crc16()
        let bytes = [UInt8](data)
        let bytesPtr = bytes.withContiguousStorageIfAvailable {
            (ptrHeader: UnsafeBufferPointer<UInt8>) in
            return ptrHeader.baseAddress! + (bytes.count - 2)
        }
        let crcInData = bytesPtr?.withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        if crcInData == nil || crcInData != crc {
            return nil
        }

        let pair = WoWFKVPair()
        
        var currentIndex = 0
        let typeSize = MemoryLayout<WoWFKVPairType>.size
        let valueTypePtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + currentIndex
        }
        let valueTypeData = valueTypePtr?.withMemoryRebound(to: WoWFKVPairType.self, capacity: typeSize) {
            $0.pointee
        }
        currentIndex = currentIndex + typeSize
        pair.valueType = valueTypeData ?? .isNil

        let versionSize = MemoryLayout<UInt32>.size
        let versionPtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + currentIndex
        }
        let versionData = versionPtr?.withMemoryRebound(to: UInt32.self, capacity: versionSize) {
            $0.pointee
        }
        currentIndex = currentIndex + versionSize
        pair.version = versionData ?? 0

        let objcTypeLenSize = MemoryLayout<Int>.size
        let objcTypeLenPtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + currentIndex
        }
        
        let objcTypeLenData = objcTypeLenPtr?.withMemoryRebound(to: Int.self, capacity: objcTypeLenSize) {
            $0.pointee
        }
        currentIndex = currentIndex + objcTypeLenSize
        
        let keyLenSize = MemoryLayout<Int>.size
        let keyLenSizePtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + currentIndex
        }
        
        let keyLenData = keyLenSizePtr?.withMemoryRebound(to: Int.self, capacity: keyLenSize) {
            $0.pointee
        }
        currentIndex = currentIndex + keyLenSize
        
        let dataLenSize = MemoryLayout<Int>.size
        let dataLenSizePtr = bytes.withContiguousStorageIfAvailable {
            (ptr: UnsafeBufferPointer<UInt8>) in
            return ptr.baseAddress! + currentIndex
        }
        let dataLenData = dataLenSizePtr?.withMemoryRebound(to: Int.self, capacity: dataLenSize) {
            $0.pointee
        }
        currentIndex = currentIndex + dataLenSize

        if let objcTypeLen = objcTypeLenData {
            let objcTypeBytes = bytes[currentIndex..<currentIndex + objcTypeLen]
            pair.objcType = String(bytes: objcTypeBytes, encoding: .utf8)
            currentIndex = currentIndex + objcTypeLen
        }
        
        if let keyLen = keyLenData {
            let keyBytes = bytes[currentIndex..<currentIndex + keyLen]
            pair.key = String(bytes: keyBytes, encoding: .utf8)
            currentIndex = currentIndex + keyLen
        }
        
        let dataLen: Int = dataLenData ?? 0
        switch valueTypeData {
        case .isRemoved, .isNil:
            break
        case .isBool:
            let dataPtr = bytes.withContiguousStorageIfAvailable {
                (ptr: UnsafeBufferPointer<UInt8>) in
                return ptr.baseAddress! + currentIndex
            }
            let boolValue = dataPtr?.withMemoryRebound(to: Bool.self, capacity: MemoryLayout<Bool>.size) {
                $0.pointee
            }
            pair.boolValue = boolValue
        case .isInt32:
            let dataPtr = bytes.withContiguousStorageIfAvailable {
                (ptr: UnsafeBufferPointer<UInt8>) in
                return ptr.baseAddress! + currentIndex
            }
            let int32Value = dataPtr?.withMemoryRebound(to: Int32.self, capacity: MemoryLayout<Int32>.size) {
                $0.pointee
            }
            pair.int32Value = int32Value
        case .isInt64:
            let dataPtr = bytes.withContiguousStorageIfAvailable {
                (ptr: UnsafeBufferPointer<UInt8>) in
                return ptr.baseAddress! + currentIndex
            }
            let int64Value = dataPtr?.withMemoryRebound(to: Int64.self, capacity: MemoryLayout<Int64>.size) {
                $0.pointee
            }
            pair.int64Value = int64Value
        case .isFloat:
            let dataPtr = bytes.withContiguousStorageIfAvailable {
                (ptr: UnsafeBufferPointer<UInt8>) in
                return ptr.baseAddress! + currentIndex
            }
            let floatValue = dataPtr?.withMemoryRebound(to: Float.self, capacity: MemoryLayout<Float>.size) {
                $0.pointee
            }
            pair.floatValue = floatValue
        case .isDouble:
            let dataPtr = bytes.withContiguousStorageIfAvailable {
                (ptr: UnsafeBufferPointer<UInt8>) in
                return ptr.baseAddress! + currentIndex
            }
            let doubleValue = dataPtr?.withMemoryRebound(to: Double.self, capacity: MemoryLayout<Double>.size) {
                $0.pointee
            }
            pair.doubleValue = doubleValue
        case .isString:
            let dataBytes = bytes[currentIndex..<currentIndex + dataLen]
            pair.stringValue = String(bytes: dataBytes, encoding: .utf8)
        case .isData:
//            let dataPtr = bytes.withContiguousStorageIfAvailable {
//                (ptr: UnsafeBufferPointer<UInt8>) in
//                return ptr.baseAddress! + currentIndex
//            }
//            // 这里传指针
//            pair.binaryValue = Data(bytes: dataPtr!, count: dataLen)
            // 这里两种方式获取
            let dataBytes = bytes[currentIndex..<currentIndex + dataLen]
            pair.binaryValue = Data(dataBytes)
        case .none:
            break
        }
        
        return pair
    }

    func representationData() -> Data {
        var data = Data()

        // append valueType Data
        let valuePtr = UnsafeMutablePointer<WoWFKVPairType>.allocate(capacity: 1)
        valuePtr.pointee = self.valueType
        let valuePtr_8 = valuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<WoWFKVPairType>.size) { $0 }
        data.append(valuePtr_8, count: MemoryLayout<WoWFKVPairType>.size)
        
        // append version Data
        let versionPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        versionPtr.pointee = self.version ?? 0
        let versionPtr_8 = versionPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size) { $0 }
        data.append(versionPtr_8, count: MemoryLayout<UInt32>.size)
        
        // 添加头部
        var objcTypeLen: Int = 0
        if let objcTypeData = self.objcType?.data(using: .utf8) {
            let objcTypeBytes = [UInt8](objcTypeData)
            objcTypeLen = objcTypeBytes.count
        }
        let objcTypeLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        objcTypeLenPtr.pointee = objcTypeLen
        let objcTypeLenPtr_8 = objcTypeLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
        data.append(objcTypeLenPtr_8, count: MemoryLayout<Int>.size)
        
        var keyLen: Int = 0
        if let keyData = self.key?.data(using: .utf8) {
            let keyBytes = [UInt8](keyData)
            keyLen = keyBytes.count
        }
        let keyLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        keyLenPtr.pointee = keyLen
        let keyLenPtr_8 = keyLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
        data.append(keyLenPtr_8, count: MemoryLayout<Int>.size)
        
        var dataLen: Int = 0
        switch valueType {
        case .isRemoved, .isNil:
            dataLen = 0
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
        case .isBool:
            dataLen = MemoryLayout<Bool>.size
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            let dataValuePtr = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            dataValuePtr.pointee = self.boolValue ?? false
            let dataValuePtr_8 = dataValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Bool>.size) { $0 }
            data.append(dataValuePtr_8, count: MemoryLayout<Bool>.size)
        case .isInt32:
            dataLen = MemoryLayout<Int32>.size
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            let dataValuePtr = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            dataValuePtr.pointee = self.int32Value ?? 0
            let dataValuePtr_8 = dataValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int32>.size) { $0 }
            data.append(dataValuePtr_8, count: MemoryLayout<Int32>.size)
        case .isInt64:
            dataLen = MemoryLayout<Int64>.size
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            let dataValuePtr = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
            dataValuePtr.pointee = self.int64Value ?? 0
            let dataValuePtr_8 = dataValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int64>.size) { $0 }
            data.append(dataValuePtr_8, count: MemoryLayout<Int64>.size)
        case .isFloat:
            dataLen = MemoryLayout<Float>.size
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            let dataValuePtr = UnsafeMutablePointer<Float>.allocate(capacity: 1)
            dataValuePtr.pointee = self.floatValue ?? 0
            let dataValuePtr_8 = dataValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Float>.size) { $0 }
            data.append(dataValuePtr_8, count: MemoryLayout<Float>.size)
        case .isDouble:
            dataLen = MemoryLayout<Double>.size
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            let dataValuePtr = UnsafeMutablePointer<Double>.allocate(capacity: 1)
            dataValuePtr.pointee = self.doubleValue ?? 0
            let dataValuePtr_8 = dataValuePtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Double>.size) { $0 }
            data.append(dataValuePtr_8, count: MemoryLayout<Double>.size)
        case .isString:
            if let stringVal = self.stringValue,
               let stringData = stringVal.data(using: .utf8) {
                let stringBytes = [UInt8](stringData)
                dataLen = stringBytes.count
            } else {
                dataLen = 0
            }
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            if let valueData = self.stringValue?.data(using: .utf8) {
                data.append(valueData)
            }
        case .isData:
            if let binaryVal = self.binaryValue {
                dataLen = binaryVal.count
            } else {
                dataLen = 0
            }
            let dataLenPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataLenPtr.pointee = dataLen
            let dataLenPtr_8 = dataLenPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int>.size) { $0 }
            data.append(dataLenPtr_8, count: MemoryLayout<Int>.size)
            if let objcTypeData = self.objcType?.data(using: .utf8) {
                data.append(objcTypeData)
            }
            if let keyData = self.key?.data(using: .utf8) {
                data.append(keyData)
            }
            if let valueData = self.binaryValue {
                data.append(valueData)
            }
        }
        
        // CRC check code
        let crc = data.fkv_crc16()
        let crcPtr = UnsafeMutablePointer<UInt16>.allocate(capacity: 1)
        crcPtr.pointee = crc
        let crcPtr_8 = crcPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt16>.size) { $0 }
        data.append(crcPtr_8, count: MemoryLayout<UInt16>.size)
        return data
    }
}

extension WoWFKVPair: Equatable {
    public static func == (lhs: WoWFKVPair, rhs: WoWFKVPair) -> Bool {
        var result = true
        switch lhs.valueType {
        case .isRemoved, .isNil:
            result = true
        case .isBool:
            result = result && (lhs.boolValue == rhs.boolValue)
        case .isInt32:
            result = result && (lhs.int32Value == rhs.int32Value)
        case .isInt64:
            result = result && (lhs.int64Value == rhs.int64Value)
        case .isFloat:
            result = result && (lhs.floatValue == rhs.floatValue)
        case .isDouble:
            result = result && (lhs.doubleValue == rhs.doubleValue)
        case .isString:
            result = result && (lhs.stringValue == rhs.stringValue)
        case .isData:
            result = result && (lhs.binaryValue == rhs.binaryValue)
        }
        return result
    }
}

public final class WoWFKVPairList {
    var items = [WoWFKVPair]()
}

extension WoWFKVPairList: WoWFKVCoding {
    static func parse(from data: Data) throws -> Any? {
        let len = data.count
        let delimiterData = WoWFastKVSeperatorString.data(using: .utf8)!
        
        let kvList = WoWFKVPairList()
        
        var delimiterRange: Range<Int>?
        var splitStartIndex = 0
        while true {
            delimiterRange = data.range(of: delimiterData, options: [], in: splitStartIndex..<len)
            if delimiterRange == nil || delimiterRange?.isEmpty == nil || delimiterRange!.isEmpty == true {
                break
            }
            let kv = try? WoWFKVPair.parse(from: data.subdata(in: splitStartIndex..<delimiterRange!.lowerBound))
            if let kvItem = kv as? WoWFKVPair {
                kvList.items.append(kvItem)
            }
            splitStartIndex = delimiterRange!.upperBound
        }
        return kvList
    }
    
    func representationData() -> Data {
        var data = Data()
        items.forEach { pairItem in
            data.append(pairItem.representationData())
            data.append(WoWFastKVSeperatorString.data(using: .utf8)!)
        }
        return data
    }
}

// MARK: - CRC16校验
extension Data {
    func fkv_crc16() -> UInt16 {
        let bytes = [UInt8](self)
        return CRC16.instance.getCrc(data: bytes)
    }
}

