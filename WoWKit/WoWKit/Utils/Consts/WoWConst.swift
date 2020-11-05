//
//  WoWConst.swift
//  WoW-Example
//  UI & 布局 适配的全局配置
//  Created by Silence on 2020/11/5.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

/// UI / 布局
public enum WoWDisplay {
    public static let screenBounds = UIScreen.main.bounds
    public static let screenSize = WoWDisplay.screenBounds.size
    public static let screenWidth = WoWDisplay.screenSize.width
    public static let screenHeight = WoWDisplay.screenSize.height
}

/// 文件系统
public enum WoWFileSystem {
    public static let homeDirectory = NSHomeDirectory()
    public static let tempDirectory = NSTemporaryDirectory()
    public static let bundlePath = Bundle.main.bundlePath
}
