//
//  WoWWebView.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/22.
//  Copyright © 2020 Silence. All rights reserved.
//

import WebKit

open class WoWWebView: WKWebView, WoWViewProtocol {
    deinit {
        super.navigationDelegate = nil
    }
    
    // 标注当前WebView禁止重用，直接销毁
    open var invalidForReuse: Bool {
        get {
            return super.invalid
        }
        set {
            super.invalid = newValue
        }
    }
    
    public final override func componentViewWillLeavePool() {
        super.componentViewWillLeavePool()
        _wowWebViewWillLeavePool()
    }

    open func _wowWebViewWillLeavePool() {
        
    }
    
    public final override func componentViewWillEnterPool() {
        super.componentViewWillEnterPool()
        _wowWebViewWillEnterPool()
    }
    
    open func _wowWebViewWillEnterPool() {
        
    }
    
    public func clearBackForwardList() {
        super._clearBackForwardList()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

public typealias WoWWebViewJSCompletionHandler = ((Any) -> Void)

extension WoWWebView {
    public func safeAsyncEvaluateJavaScriptString(_ script: String, completionHandler: WoWWebViewJSCompletionHandler? = nil) {
        super._safeAsyncEvaluateJavaScriptString(script, completionHandler: completionHandler)
    }
    
    func setCookie(name: String,
                   value: String,
                   domain: String? = nil,
                   path: String? = nil,
                   expiresDate: Date? = nil,
                   completionHandler: WoWWebViewJSCompletionHandler? = nil) {
        super._setCookie(with: name, value: value, domain: domain, path: path, expiresDate: expiresDate, completionHandler: completionHandler)
    }
    
    func deleteCookie(name: String,
                      completionHandler: WoWWebViewJSCompletionHandler? = nil) {
        super._deleteCookie(with: name, completionHandler: completionHandler)
    }
    
    func getAllCustomCookieName() -> Dictionary<String, String>.Keys? {
        return super._getAllCustomCookiesName
    }
    
    func deleteAllCuntomCookies() {
        super._deleteAllCustomCookies()
    }
}
