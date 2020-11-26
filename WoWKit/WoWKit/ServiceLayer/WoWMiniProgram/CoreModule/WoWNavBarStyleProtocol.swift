//
//  WoWNavBarStyleProtocol.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/26.
//

import UIKit

protocol WoWNavBarStyleProtocol: class {
    func customMPStyleNavBar()
}

extension WoWMiniWebViewController: WoWNavBarStyleProtocol {
    var navigationHeight: CGFloat {
        guard let navigatorBar = navigationController?.navigationBar else {
            return statusBarHeight
        }
        return statusBarHeight + navigatorBar.frame.height
    }
    
    var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    func customMPStyleNavBar() {
        let titleBarH: Int = 32
        let titleBarW: Int = 87
        let titleBarImageView = UIImageView()
        
        titleBarImageView.frame.size = CGSize(width: titleBarW, height: titleBarH)
        titleBarImageView.image = UIImage(named: "titlebar")
        
        let buttonView = UIBarButtonItem(customView: titleBarImageView)
        
        let size = CGSize(width: titleBarW / 2, height: titleBarH)
        let detailButton = UIButton()
        let closeButton = UIButton()
        
        detailButton.frame.size = size
        
        closeButton.frame.origin = CGPoint(x: size.width, y: 0)
        closeButton.frame.size = size
        
        titleBarImageView.addSubview(detailButton)
        titleBarImageView.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeMiniProgram(sender:)), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(showMiniProgramTool(sender:)), for: .touchUpInside)

        navigationItem.rightBarButtonItems = [buttonView]
    }
    
    @objc func closeMiniProgram(sender: Any) {
        WoWMPEngineContext.shared.getMiniProgramEngine(appId: self.appId)?.close()
    }
    
    @objc func showMiniProgramTool(sender: Any) {
        
    }
}
