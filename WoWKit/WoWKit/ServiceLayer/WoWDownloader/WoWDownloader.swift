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
    private var ongoingDownloads: [String: WoWDownloadTaskWrapper] = [:]
    private var backgroundSession: URLSession!
    
    public var backgroundCompletionHandler: BackgroundDownloadCompletionHandler?
    public var showLocalNotificationOnBackgroundDownloadDone = true
    public var localNotificationText: String?
    
    // MARK: - Singleton
    public static let shared: WoWDownloader = {
        return WoWDownloader()
    }
    
    // MARK: - Public Methods
    public func dowloadFile(with request: URLRequest,
                            in directory: String? = nil,
                            with fileName: String? = nil,
                            shouldDownloadInBackground: Bool = false,
                            onProgress progressClosure: DownloadProgressClosure? = nil,
                            onCompletion completionClosure: @escaping DownloadCompletionClosure) -> String? {
        if let _ = self.ongoingDownloads[(request.url?.absoluteString)!] {
            debugPrint("【Download】Task: \(request.url?.absoluteString!) has already in progress.")
            return nil
        }
        
        var downloadTask: URLSessionDownloadTask
        if shouldDownloadInBackground {
            downloadTask = self.backgroundSession.downloadTask(with: request)
        } else {
            downloadTask = self.session.downloadTask(with: request)
        }
        
        let download = WoWDownloadTaskWrapper(downloadTask: downloadTask,
                                              progressClosure: progressClosure,
                                              completionClosure: completionClosure,
                                              fileName: fileName,
                                              directoryName: directory)
        let key = (request.url?.absoluteString)!
        self.ongoingDownloads[key] = download
        downloadTask.resume()
        return key
    }
    
    public func currentDownloads() -> [String] {
        return Array(self.ongoingDownloads.keys)
    }
    
    public func cancelAllDownloads() {
        self.ongoingDownloadss.forEach {
            let downloadTask = $1.downloadTask
            downloadTask.cancel()
        }
        self.ongoingDownloads.removeAll()
    }
    
    public func cancelDownload(for uniqueKey: String) {
        let (presence, download) = self.isDownloadInProgress(for: uniqueKey)
        if presence == true, let downloadTask = download?.downloadTask {
            downloadTask.cancel()
            self.ongoingDownloads.removeValue(forKey: uniqueKey)
        }
    }
    
    public func isDownloadInProgress(for key: String?) {
        let (isInProgress, _) = self.isDownloadInProgress(for: key)
        return isInProgress
    }
    
    public func alterHandlersForOngoingDownload(
        for uniqueKey: String?,
        setProgress progressClosure: DownloadProgressClosure?,
        setCompletion completionClosure: @escaping DownloadCompletionClosure?) {
        let (presence, download) = self.isDownloadInProgress(for: uniqueKey)
        if presence == true, let download = download {
            download.progressClosure = progressClosure
            download.completionClosure = completionClosure
        }
    }
    
    // MARK: - Private Methods
    private override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier)
        self.backgroundSession = URLSession(configuration: backgroundSession, delegate: self, delegateQueue: OperationQueue())
    }
    
    private func isDownloadInProgress(for uniqueKey: String?) -> (Bool, WoWDownloadTaskWrapper?) {
        guard let key = uniqueKey else {
            return (false, nil)
        }
        for (uniqueKey, download) in self.ongoingDownloads {
            if uniqueKey == key {
                return (true, download)
            }
        }
        return (false, nil)
    }
}

extension WoWDownloader: URLSessionDelegate, URLSessionDownloadDelegate {
    
}
