//
//  URL+query.swift
//  WoWMiniProgram
//
//  Created by Silence on 2020/11/18.
//

import Foundation

extension URL {
    var wowQuery: [String: String] {
        guard let query = self.query else { return [:]}
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}
