//
//  Dictionary+toJSON.swift
//  WoWKitDependency
//
//  Created by Silence on 2020/11/17.
//

import Foundation

extension Dictionary {
    func toJSON() throws -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            throw error
        }
    }
}
