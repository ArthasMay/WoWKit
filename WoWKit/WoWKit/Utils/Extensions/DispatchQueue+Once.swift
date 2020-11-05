//
//  DispatchQueue+Once.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/23.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceToken.contains(token) {
            return
        }
        _onceToken.append(token)
        block()
    }
}
