//
//  Benchmark.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/22.
//  Copyright © 2020 Silence. All rights reserved.
//

import Foundation

/// benchmark: 性能基准测试函数
/// - Parameter testClosure: 测试的代码块
/// - Returns: 性能测试时间
public func benchmark(testClosure: (() -> Void)) -> CFTimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    testClosure()
    let endTime = CFAbsoluteTimeGetCurrent()
    return ((endTime - startTime) * 1000)
}
