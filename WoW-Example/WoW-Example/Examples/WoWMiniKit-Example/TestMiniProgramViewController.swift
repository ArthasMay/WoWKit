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
    var server: GCDWebServer?
    
    var rZip = "http://10.253.36.19:8001/build.zip"
    
    let tmpRuntimeDir = WoWFileSystem.tempDirectory.appending("MPRuntime/")
    let mpRuntimeDir = WoWFileSystem.homeDirectory.appending("/Documents/MPRuntime")
    
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
    
    func startServer() {
//        WoWDownloader.shared.dowloadFile(with: URLRequest(url: URL(string: rZip)!)) { (error, tmpZipUrl) in
//            if error != nil {
//                logger.error(error?.localizedDescription)
//                return
//            }
//
//            do {
//                try SSZipArchive.unzipFile(atPath: tmpZipUrl!.path, toDestination: tmpRuntimeDir, overwrite: true, password: nil)
//            } catch {
//
//                return
//            }
//        }
        
    }
}
