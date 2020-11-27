//
//  TestMiniKitViewController.swift
//  WoW-Example
//
//  Created by Silence on 2020/11/4.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import WoWMiniProgram
import WoWKitDependency

class TestMiniProgramViewController: UIViewController {
    
    @IBOutlet weak var appIdTF: UITextField!
    @IBOutlet weak var urlTF: UITextField!
    
    override func viewDidLoad() {
        appIdTF.text = "wxe158997d136c164e"
        urlTF.text = "http://10.253.36.19:8001/"
    }
    
    @IBAction func runDemo(_ sender: Any) {
        guard let urlStr = urlTF.text, let appId = appIdTF.text else {
            logger.error("【MPDemo】：MiniProgram资源配置错误！")
            return
        }
        
        let mpZipUrlStr = urlStr.appending(appId).appending(".zip")
        let mpZipUrl = URL(string: mpZipUrlStr)!
        
        WoWMPRunningBootstrap().run(appId, mpZipUrl);
    }
}
