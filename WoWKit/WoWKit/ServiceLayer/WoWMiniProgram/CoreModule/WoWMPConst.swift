//
//  WoWMPConst.swift
//  WoW-Example
//  WoWMiniProgram 全局变量存储
//  Created by Silence on 2020/11/5.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation
import WoWKitDependency

enum WoWMPConfig {
    static let miniProgramDir = WoWFileSystem.homeDirectory.appending("/Documents/MiniPrograme")
    static let libraryDir = WoWFileSystem.homeDirectory.appending("/Documents/library")
    static let mpTempDir = WoWFileSystem.tempDirectory.appending("MiniPrograme")
}

enum InvokeJSCoreType: Int {
    
}
