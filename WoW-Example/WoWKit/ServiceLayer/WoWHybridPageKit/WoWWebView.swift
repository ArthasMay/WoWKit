//
//  WoWWebView.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/22.
//  Copyright © 2020 Silence. All rights reserved.
//

import WebKit

open class WoWWebView: WKWebView {
    // 标注当前WebView禁止重用，直接销毁
    open var invalidForReuse = false

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
