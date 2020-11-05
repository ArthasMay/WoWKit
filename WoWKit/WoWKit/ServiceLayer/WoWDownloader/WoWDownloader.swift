//
//  WoWDownloader.swift
//  WoWKit
//
//  Created by Silence on 2020/11/5.
//

import Foundation
import UserNotifications

final public class WoWDownloader: NSObject {
    public typealias DownloadCompletionClosure = (_ err: Error?, _ fileUrl: URL?) -> Void
    public typealias DownloadProgressClosure = (_ progress: Float) -> Void
    public typealias BackgroundDownloadCompletionHandler = () -> Void
    
    // MARK: - Properties
    private var session: URLSession!
    private var goingonDownloadTasks: [String: WoWDownloadTask] = [:]
    private var backgroundSession: URLSession!
    
    
}
