//
//  WKWebView+WoWExtension.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/23.
//  Copyright © 2020 Silence. All rights reserved.
//

import WebKit

public protocol WoWReusableWebViewProtocol {
    func componentViewWillLeavePool()
    func componentViewWillEnterPool()
}

/// 通过Extension实现了协议的默认方法，相当于实现了optional
extension WoWReusableWebViewProtocol {
    public func componentViewWillLeavePool() {}
    public func componentViewWillEnterPool() {}
}

fileprivate class WoWWeakWrapper {
    
}

extension WKWebView: WoWReusableWebViewProtocol {
//    weak var holderObject: AnyObject?
}
