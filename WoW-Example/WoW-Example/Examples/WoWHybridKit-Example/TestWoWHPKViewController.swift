//
//  TestWoWHPKViewController.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/26.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

class TestWebView: WoWWebView {}

class TestWoWHPKViewController: UIViewController {
    
    deinit {
        WoWHybridPageManager.shared.enqueue(webView: webView)
    }

    var webView: TestWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview({
            webView = WoWHybridPageManager.shared.dequeueWebView(with: TestWebView.self, webViewHolder: self)
            let navH = (navigationController?.navigationBar.frame.height ?? 0) + 44
            webView.frame = CGRect(x: 0, y: navH, width: view.frame.width, height: view.frame.height - navH)
            return webView
        }())
        
        webView.load(URLRequest(url: URL(string: "https://www.jianshu.com/p/7ba59affeaa2")!))
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
