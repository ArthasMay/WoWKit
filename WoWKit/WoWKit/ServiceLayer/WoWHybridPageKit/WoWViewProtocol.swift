//
//  WoWViewProtocol.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/26.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

public protocol WoWViewProtocol {
    func componentViewWillLeavePool()
    func componentViewWillEnterPool()
}

extension WoWViewProtocol {
    func componentViewWillLeavePool() {}
    func componentViewWillEnterPool() {}
}
