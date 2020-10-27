//
// WKWebView+WoWReusable.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/23.
//  Copyright © 2020 Silence. All rights reserved.
//

import WebKit

protocol WoWReusableWebViewProtocol {
    func componentViewWillLeavePool()
    func componentViewWillEnterPool()
}

/// 通过Extension实现了协议的默认方法，相当于实现了optional
extension WoWReusableWebViewProtocol {
    public func componentViewWillLeavePool() {}
    public func componentViewWillEnterPool() {}
}

fileprivate class WoWWeakWrapper {
    weak var weakObj: AnyObject?
}

extension WKWebView: WoWReusableWebViewProtocol {
    private struct AssociatedKeys {
        static var holderObjectAssociateKey = "holderObjectAssociateKey"
        static var reusedTimesAssociateKey  = "reusedTimesAssociateKey"
        static var invalidAssociateKey      = "invalidAssociateKey"
    }
    
    weak var holderObject: AnyObject? {
        get {
            if let wrapObj = objc_getAssociatedObject(self, &AssociatedKeys.holderObjectAssociateKey) as? WoWWeakWrapper {
                return wrapObj.weakObj
            }
            return nil
        }
        set {
            if let wrapObj = objc_getAssociatedObject(self, &AssociatedKeys.holderObjectAssociateKey) as? WoWWeakWrapper {
                wrapObj.weakObj = newValue
            } else {
                let wrapObj = WoWWeakWrapper()
                wrapObj.weakObj = newValue
                objc_setAssociatedObject(self, &AssociatedKeys.holderObjectAssociateKey, wrapObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var reusedTimes: Int {
        get {
            if let reusedTimesNum = objc_getAssociatedObject(self, &AssociatedKeys.reusedTimesAssociateKey) as? NSNumber {
                return reusedTimesNum.intValue
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.reusedTimesAssociateKey, NSNumber(integerLiteral: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var invalid: Bool {
        get {
            if let invalidNum = objc_getAssociatedObject(self, &AssociatedKeys.invalidAssociateKey) as? NSNumber {
                return invalidNum.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.invalidAssociateKey, NSNumber(booleanLiteral: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Clear backForwardList
    func _clearBackForwardList() {
        let sel = NSSelectorFromString("_re" + "moveA" + "llIte" + "ms")
        if backForwardList.responds(to: sel) == true {
            backForwardList.perform(sel)
        }
    }
}

/// WoWReusableWebViewProtocol
extension WKWebView {
    @objc
    func componentViewWillLeavePool() {
        reusedTimes = reusedTimes + 1;
        _clearBackForwardList()
    }
    
    @objc
    func componentViewWillEnterPool() {
        holderObject = nil
        scrollView.delegate = nil
        scrollView.isScrollEnabled = true
        stopLoading()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let reuseLoadUrl = WoWHybridPageManager.shared.webViewReuseLoadUrl
        if reuseLoadUrl.count > 0 {
            self.load(URLRequest(url: URL(string: reuseLoadUrl)!))
        } else {
            self.loadHTMLString("", baseURL: nil)
        }
    }
}
