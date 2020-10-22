//
//  TestKVCodableObject.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/21.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

public struct TestKVCodable {
    var name: String
}
extension TestKVCodable: Codable {}
