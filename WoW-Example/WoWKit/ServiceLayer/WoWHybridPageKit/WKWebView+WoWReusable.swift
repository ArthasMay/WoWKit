//
//  WKWebView+WoWReusable.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/23.
//  Copyright © 2020 Silence. All rights reserved.
//

import WebKit

public typealias _WoWWebViewJSCompletionHandler = ((Any) -> Void)
public enum ConfigUAType: NSInteger {
    case replace = 0       // replace all UA string
    case append            // append to original UA string
}

extension WKWebView {
    // MARK: - Safe evaluate js
    public func _safeAsyncEvaluateJavaScriptString(_ script: String, completionHandler: _WoWWebViewJSCompletionHandler? = nil) {
        if Thread.current.isMainThread == false {
            DispatchQueue.main.async { [weak self] in
                // retain self
                if let `self` = self {
                    self._safeAsyncEvaluateJavaScriptString(script, completionHandler: completionHandler)
                }
            }
            return
        }
        
        if script.count <= 0 {
            // TODO: 输出错误日志: 【WoWHybridPageKit】 Invalid script
            if let cmpHandler = completionHandler {
                cmpHandler("")
            }
            return
        }
        
        self.evaluateJavaScript(script) { [weak self] (result, error) in
            guard let `self` = self else { return }
            let _ = self
            var resultObj: Any = ""
            if error != nil {
                if result == nil || result is NSNull {
                    resultObj = ""
                } else if result is NSNumber {
                    resultObj = "\((result as! NSNumber).stringValue)"
                } else if result is NSObject {
                    resultObj = result as! NSObject
                } else {
                    // TODO: 输出错误日志: 【WoWHybridPageKit】evaluate js return type:%@, js:%@
                }
            }
            if let cmpHandler = completionHandler {
                cmpHandler(resultObj)
            } else {
                // TODO: 输出错误日志: 【WoWHybridPageKit】evaluate js Error : %@
                if let cmpHandler = completionHandler {
                    cmpHandler("")
                }
            }
        }
    }
    
    // MARK: - Cookies
    private struct AssociatedKeys {
        static var AssociatedKey_CookieDic = "AssociatedKey_CookieDic"
    }
    
    var cookieDic: [String: String]? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.AssociatedKey_CookieDic, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.AssociatedKey_CookieDic) as? [String: String]
        }
    }
    
    public func _setCookie(with name: String,
                           value: String,
                           domain: String? = nil,
                           path: String? = nil,
                           expiresDate: Date? = nil,
                           completionHandler: _WoWWebViewJSCompletionHandler? = nil
    ) {
        guard name.count > 0 else {
            return
        }
        
        var cookieScript = "document.cookie='\(name)=\(value);"
        if let tDomain = domain {
            cookieScript = cookieScript + "domain=\(tDomain);"
        }
        if let tPath = path {
            cookieScript = cookieScript + "path=\(tPath);"
        }
        
        if cookieDic == nil {
            cookieDic = [String: String]()
        }
        cookieDic![name] = cookieScript
        
        if let tExpiresDate = expiresDate, tExpiresDate.timeIntervalSince1970 != 0 {
            cookieScript = cookieScript + "expires='+(new Date(\(tExpiresDate.timeIntervalSince1970 * 1000).toUTCString());"
        } else {
            cookieScript = cookieScript + "'"
        }
        cookieScript = cookieScript + "\n"
        self._safeAsyncEvaluateJavaScriptString(cookieScript, completionHandler: completionHandler)
    }
    
    public func _deleteCookie(with name: String, completionHandler: _WoWWebViewJSCompletionHandler? = nil) {
        guard name.count > 0 else {
            return
        }
        if cookieDic?.keys.contains(name) == false {
            return
        }
        var cookieScript = ""
        cookieScript = cookieScript + cookieDic![name]!
        cookieScript = cookieScript + "expires='+(new Date(0).toUTCString());\n"
        cookieDic?.removeValue(forKey: name)
        self._safeAsyncEvaluateJavaScriptString(cookieScript, completionHandler: completionHandler)
    }
    
    public var allCustiomCookies: Dictionary<String, String>.Keys? {
        return cookieDic?.keys
    }
    
    public func _deleteAllCustomCookies() {
        allCustiomCookies?.forEach({
            _deleteCookie(with: $0)
        })
    }
    
    
    // MARK: - UA
    @available(iOS 9.0, *)
    public class func configCustomUA(with type: ConfigUAType, customUAString: String) {
        guard customUAString.count > 0 else {
            return
        }
        
        if type == .replace {
            let dictionary = ["UserAgent": customUAString]
            UserDefaults.standard.register(defaults: dictionary)
        } else if type == .append {
            // 同步获取WebView的UserAgent
            var originalUserAgent: String?
            let webView = WKWebView()
            let privateUASel = NSSelectorFromString("_" + "user" + "Agent")
            if webView.responds(to: privateUASel) {
                originalUserAgent = webView.perform(privateUASel).retain().takeRetainedValue() as? String
            }
            
            if let tOriginalUA = originalUserAgent {
                let appUserAgent = tOriginalUA + "-" + customUAString
                let dictionary = ["UserAgent": appUserAgent]
                UserDefaults.standard.register(defaults: dictionary)
            }
        } else {
            // TODO: 输出错误日志: 【WoWHybridPageKit】WKWebView (SyncConfigUA) config with invalid type :%@
        }
    }
    
    // MARK: - Cache
    public class func safeClearAllCache() {
        let websiteDataTypes: Set = [
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ]
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date) {
            // TODO: 【WoWHybridPageKit】("Clear All Cache Done")
        }
    }

    // MARK: - Fix menu items
    public class func fixWKWebViewMenuItems() {
        DispatchQueue.once {
            let cls: AnyClass? = NSClassFromString("W" + "K" + "Content" + "View")
            if let tCls = cls {
                let fixSel = #selector(self.canPerformAction(_:withSender:))
                let method = class_getInstanceMethod(tCls, fixSel)
                assert(method != nil, "Selector \(NSStringFromSelector(fixSel)) not found in %@ methods of class \(class_isMetaClass(tCls) ? "class" : "instance").")
                let originalIMP = method_getImplementation(method!)
                typealias originalImplementationType = @convention(c) (AnyObject, Selector, Selector, AnyObject) -> Bool
                let originClosure: originalImplementationType = unsafeBitCast(originalIMP, to: originalImplementationType.self)
                let newBlock: @convention(block) (Self, Selector, AnyObject) -> Bool = {
                    (self, action, sender) in
                    if action == #selector(self.cut(_:)) || action == #selector(self.copy(_:)) || action == #selector(self.paste(_:)) || action == #selector(self.delete(_:)) {
                        return originClosure(self, fixSel, action, sender)
                    } else {
                        return false
                    }
                }

                let newIMP = imp_implementationWithBlock(newBlock)
                class_replaceMethod(tCls, fixSel, newIMP, method_getTypeEncoding(method!))
            } else {
                // TODO: 输出错误日志: 【WoWHybridPageKit】WKWebView (DeleteMenuItems) can not find valid class
            }
        }
    }
    
    // MARK: - Disable double click
    public class func disableWebViewDoubleClick() {
        
    }
}
