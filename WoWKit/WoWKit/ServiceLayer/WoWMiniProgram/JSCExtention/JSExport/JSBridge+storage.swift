//
//  JSBridge+storage.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation

extension JSBridge {
    static func getStorage(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        let storage = UserDefaults.standard.dictionary(forKey: option.appId!) ?? [:]
        
        guard let params = option.payload as? [String] else {
            callback(storage)
            return
        }
        
        guard let key: String = params.first else {
            callback(storage)
            return
        }
        
        callback(storage[key])
    }
    
    static func setStorage(option: JSInvokeNativeOption, callback: @escaping (Any?) -> Void) {
        var storage = UserDefaults.standard.dictionary(forKey: option.appId!) ?? [:]
        guard let newItem = option.payload as? [Any] else {
            callback([:])
            return
        }
        guard let key = newItem.first as? String else {
            callback([:])
            return
        }
        storage[key] = newItem.last
        callback([key:newItem.last])
        UserDefaults.standard.setValue(storage, forKey: option.appId!)
    }
}
