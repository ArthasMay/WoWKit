//
//  ViewController.swift
//  WoW-Example
//
//  Created by Silence on 2020/9/7.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

class ExampleViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let str = "ABCD"
//        let data = str.data(using: .utf8)
//        let bytes = [UInt8](data!)
//        let u160 = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
//            $0.pointee
//        }
//        print("\(u160)")
//
//        let ptr = bytes.withContiguousStorageIfAvailable { (ptr: UnsafeBufferPointer<UInt8>) in
//            return ptr.baseAddress!
//        }
//        let u16 = ptr!.withMemoryRebound(to: String.self, capacity: 2) {
//            $0.pointee
//        }
//        print("\(u16)")
//        let tdata = bytes[2...3]
//        print(String(bytes: tdata, encoding: .utf8))
//        testData()
//        print(MemoryLayout<UInt16>.size)
//        print(MemoryLayout<UInt32>.size)
//        testData()
//        testCoding()
    }
    
    func test(a: Int, b: Int?) {
        if b == nil || b! != a {
            print("sss")
        } else {
            print("mmm")
        }
    }

    func testData() {
        var data = Data()
//        var dataApp: [UInt16] = [17475]
//        data.append(Data(bytes: &dataApp, count: 2))
//
//        var bytes = [UInt8](data)
//        let ptr = bytes.forEach {
//            print($0)
//        }
//        let ptr = UnsafeMutablePointer<WoWFKVPairType>.allocate(capacity: 1)
//        ptr.pointee = WoWFKVPairType.isNil
//        let newPtr = ptr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<WoWFKVPairType>.size) { $0 }
//        data.append(newPtr, count: 1)
//        let bytes = [UInt8](data)
//        let _ = bytes.forEach {
//            print($0)
//        }
        
//        let ptr = UnsafeMutablePointer<UInt16>.allocate(capacity: 1)
//        ptr.pointee = 17475
//        let ptr_8 = ptr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt16>.size) { $0 }
//        data.append(ptr_8, count: MemoryLayout<UInt16>.size)
//        let bytes = [UInt8](data)
//        bytes.forEach {
//            print($0)
//        }
        
        let str = "ABCD"
        data.append(str.data(using: .utf8)!)
        let bytes = [UInt8](data)
        bytes.forEach {
            print($0)
        }
        print(bytes.count)
    }

    
    func testCoding() {
        let kv = WoWFastKV.default
        
    }
}

