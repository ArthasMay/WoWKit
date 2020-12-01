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
import WebKit

class TestMiniProgramViewController: UIViewController {
    
    @IBOutlet weak var rtMPDirNameTF: UITextField!
    @IBOutlet weak var portTF: UITextField!
    @IBOutlet weak var webView: WKWebView!
    var server: GCDWebServer!
    
    var rZip = "http://10.253.36.19:8001/build.zip"
    
    let tmpRuntimeDir = WoWFileSystem.tempDirectory.appending("MPRuntime/")
    let mpRuntimeDir = WoWFileSystem.homeDirectory.appending("/Documents/MPRuntime/")
    
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
    
    func downloadResource() {
        if fs.exists(file: tmpRuntimeDir.appending("build")) {
            startServer()
            return
        }
        
        WoWRuntimeDownloader().download(URL(string: rZip)!, tmpDir: tmpRuntimeDir, dir: mpRuntimeDir) { (result) in
            if result {
                self .startServer()
            } else {
                logger.error("下载Runtime文件失败")
            }
        }
    }
    
    func startServer() {
        server = GCDWebServer()
        server.addGETHandler(forBasePath: "/", directoryPath: mpRuntimeDir.appending("build/"), indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        server.start(withPort: 8080, bonjourName: "Mini Program Runtime")
        webView.load(URLRequest(url: URL(string: "http://localhost:8080/")!))
    }
    
    
    @IBAction func start(_ sender: Any) {
        downloadResource()
    }
    
    @IBAction func end(_ sender: Any) {
        if let webServer = server, webServer.isRunning {
            webServer.stop()
            webView.load(URLRequest(url: URL(string: "http://localhost:8080/index.html")!))
        }
    }
}
