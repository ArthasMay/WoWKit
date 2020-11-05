//
//  WoWHybridPageManager.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/26.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

public class WoWHybridPageManager {
    public var componentsMaxReuseCount: Int
    public var webViewReuseLoadUrl: String
    public var webViewMaxReuseTimes: Int
    
    public static let shared = WoWHybridPageManager()
    
    private init() {
        componentsMaxReuseCount = 10
        webViewReuseLoadUrl = ""
        webViewMaxReuseTimes = Int.max
    }
}

public extension WoWHybridPageManager {
    func dequeueWebView<W: WoWWebView>(with webViewType: W.Type, webViewHolder: AnyObject?) -> W {
        return WoWWebViewPool.shared.dequeueWebView(class: webViewType, webViewHolder: webViewHolder)!
    }
    
    func enqueue<W: WoWWebView>(webView: W) {
        WoWWebViewPool.shared.enqueue(webView: webView)
    }
    
    func removeReusable<W: WoWWebView>(webView: W) {
        WoWWebViewPool.shared.removeReusable(webView: webView)
    }
    
    func clearAllReusableWebViews() {
        WoWWebViewPool.shared.clearAllReusableWebViews()
    }
    
    func clearAllReusableWebViews<W: WoWWebView>(with webViewType: W.Type) {
        WoWWebViewPool.shared.clearAllResuableWebViews(with: webViewType)
    }
    
    func reloadAllReusableWebViews() {
        WoWWebViewPool.shared.reloadAllReusableWebViews()
    }
}
