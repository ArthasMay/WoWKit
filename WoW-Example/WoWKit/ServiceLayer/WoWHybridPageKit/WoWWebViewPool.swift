//
//  WoWWebViewPool.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/26.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

class WoWWebViewPool {
    let lock: DispatchSemaphore
    var dequeueWebViews: [String: Set<WoWWebView>]!
    var enqueueWebViews: [String: Set<WoWWebView>]!
    
    static let shared = WoWWebViewPool()
    
    private init() {
        lock = DispatchSemaphore(value: 1)
        dequeueWebViews = [String: Set<WoWWebView>]()
        enqueueWebViews = [String: Set<WoWWebView>]()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        dequeueWebViews?.removeAll()
        enqueueWebViews?.removeAll()
        dequeueWebViews = nil
        enqueueWebViews = nil
    }
    
    // MARK: - Public Methods
    // 出列复用池：使用
    public func dequeueWebView<W: WoWWebView>(class webViewClass: W.Type, webViewHolder: AnyObject?) -> W? {
        guard webViewClass.isSubclass(of: WoWWebView.self) else {
//            HPKErrorLog("HPKViewPool dequeue with invalid class:%@", webViewClass);
            return nil;
        }
        
        // auto recycle
        self._tryCompactWeakHolderOfWebView()
        let dequeueWebView = _getWebView(with: webViewClass)
        dequeueWebView?.holderObject = webViewHolder
        return dequeueWebView
    }
    
    // 入列复用池：回收
    public func enqueue<W: WoWWebView>(webView: W?) {
        guard let webViewTmp = webView else {
//            HPKErrorLog(@"HPKViewPool enqueue with invalid view:%@", webView);
            return
        }

        webViewTmp.removeFromSuperview()
        if webViewTmp.reusedTimes > WoWHybridPageManager.shared.webViewMaxReuseTimes || webViewTmp.invalid == true {
            // 移除
            removeReusable(webView: webViewTmp)
        } else {
            // 回收等待使用
            _recycle(webViewTmp)
        }
    }
    
    public func reloadAllReusableWebViews() {
        lock.wait()
        for viewSet in enqueueWebViews.values {
            for webView in viewSet {
                webView.componentViewWillEnterPool()
            }
        }
        lock.signal()
    }
    
    public func clearAllReusableWebViews() {
        self._tryCompactWeakHolderOfWebView()

        lock.wait()
        enqueueWebViews.removeAll()
        lock.signal()
    }
    
    public func removeReusable<W: WoWWebView>(webView: W) {
        (webView as WoWViewProtocol).componentViewWillEnterPool()
        
        lock.wait()
        let webViewClassString = String(describing: type(of: webView))
        if dequeueWebViews.keys.contains(webViewClassString) {
            dequeueWebViews[webViewClassString]?.remove(webView)
        }
        if enqueueWebViews.keys.contains(webViewClassString) {
            enqueueWebViews[webViewClassString]?.remove(webView)
        }
        lock.signal()
    }
    
    public func clearAllResuableWebViews<W: WoWWebView>(with webViewClass: W.Type) {
        let webViewClassString = String(describing: webViewClass)
        guard webViewClassString.count > 0 else {
            return
        }

        lock.wait()
        if enqueueWebViews.keys.contains(webViewClassString) {
            enqueueWebViews.removeValue(forKey: webViewClassString)
        }
        lock.signal()
    }
    
    // MARK: - Private Methods
    private func _tryCompactWeakHolderOfWebView() {
        if let dequeueWebViewsTmp = dequeueWebViews, dequeueWebViewsTmp.count > 0 {
            for viewSet in dequeueWebViewsTmp.values {
                let webViewSetTmp = viewSet
                for webView in webViewSetTmp {
                    if webView.holderObject == nil {
                        self.enqueue(webView: webView)
                    }
                }
            }
        }
    }
    
    private func _getWebView<W: WoWWebView>(with webViewClass: W.Type) -> W? {
        let webViewClassString = String(describing: webViewClass)

        var webView: W? = nil
        lock.wait()
        if enqueueWebViews.keys.contains(webViewClassString) {
            if let viewSet = enqueueWebViews[webViewClassString], viewSet.count > 0 {
                webView = viewSet.randomElement() as? W
                if let webViewTmp = webView {
                    enqueueWebViews[webViewClassString]!.remove(webViewTmp)
                }
            }
        }
        
        if webView == nil {
            webView = webViewClass.init()
        }
        
        if let webViewTmp = webView {
            if dequeueWebViews.keys.contains(webViewClassString) {
                dequeueWebViews[webViewClassString]!.insert(webViewTmp)
            } else {
                var viewSet = Set<WoWWebView>()
                viewSet.insert(webViewTmp)
                dequeueWebViews[webViewClassString] = viewSet
            }
        }
        lock.signal()
        (webView! as WoWViewProtocol).componentViewWillLeavePool()
        return webView
    }
    
    private func _recycle<W: WoWWebView>(_ webView: W?) {
        guard let webViewTmp = webView else {
            return
        }
        
        // 进入复用池之前清理
        (webViewTmp as WoWViewProtocol).componentViewWillEnterPool()
        
        lock.wait()
        let webViewClassString = String(describing: W.self)
        if dequeueWebViews.keys.contains(webViewClassString) {
            dequeueWebViews[webViewClassString]?.remove(webView!)
        } else {
            lock.signal()
            print("WoWWebViewPool recycle invalid view")
        }

        if enqueueWebViews.keys.contains(webViewClassString) {
            if enqueueWebViews[webViewClassString]!.count < WoWHybridPageManager.shared.componentsMaxReuseCount {
                enqueueWebViews[webViewClassString]!.insert(webViewTmp)
            }
        } else {
            var viewSet = Set<WoWWebView>()
            viewSet.insert(webViewTmp)
            enqueueWebViews[webViewClassString] = viewSet
        }
        lock.signal()
    }
}
