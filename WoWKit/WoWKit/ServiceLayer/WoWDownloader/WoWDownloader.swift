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
    }()
    
    // MARK: - Public Methods
    public func dowloadFile(with request: URLRequest,
                            in directory: String? = nil,
                            with fileName: String? = nil,
                            shouldDownloadInBackground: Bool = false,
                            onProgress progressClosure: DownloadProgressClosure? = nil,
                            onCompletion completionClosure: @escaping DownloadCompletionClosure) -> String? {
        if let _ = self.ongoingDownloads[(request.url?.absoluteString)!] {
            debugPrint("【Download】Task: \((request.url?.absoluteString)!) has already in progress.")
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
        self.ongoingDownloads.forEach {
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
    
    public func isDownloadInProgress(for key: String?) -> Bool {
        let (isInProgress, _) = self.isDownloadInProgress(for: key)
        return isInProgress
    }
    
    public func alterHandlersForOngoingDownload(
        for uniqueKey: String?,
        setProgress progressClosure: DownloadProgressClosure?,
        setCompletion completionClosure: @escaping DownloadCompletionClosure) {
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
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
        self.backgroundSession = URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue())
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
    
    private func showLocalNotification(with text: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                debugPrint("【WoWDownloader】: Not authorized to schedule notification")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = text
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let identifier = "WoWDownloadManagerNotification"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    debugPrint("【WoWDownloader】: Could not schedule notification, error : \(error)")
                }
            }
        }
    }
}

extension WoWDownloader: URLSessionDownloadDelegate {
    // MARK: - Delegate
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        let key = (downloadTask.originalRequest?.url?.absoluteString)!
        if let download = self.ongoingDownloads[key] {
            if let response = downloadTask.response {
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                guard statusCode < 400 else {
                    let err = NSError(domain: "HTTPError",
                                      code: statusCode,
                                      userInfo: [
                                        NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)
                                      ])
                    OperationQueue.main.addOperation({
                        download.completionClosure(err, nil)
                    })
                    return
                }
                
                let fileName = download.fileName ?? response.suggestedFilename ?? (downloadTask.originalRequest?.url?.lastPathComponent)!
                let directory = download.directoryName
                let (fileMoveOpIsSuccess, err, finalFileUrl) = WoWFileUtils.moveFile(from: location, toDirectory: directory, with: fileName)
                OperationQueue.main.addOperation({
                    (fileMoveOpIsSuccess ? download.completionClosure(nil, finalFileUrl) : download.completionClosure(err, nil))
                })
            }
        }
        self.ongoingDownloads.removeValue(forKey: key)
    }
    
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            debugPrint("【WoWDownloader】: Could not calculate progress as totalBytesExpectedToWrite is less than 0")
            return
        }
        
        if let download = self.ongoingDownloads[(downloadTask.originalRequest?.url?.absoluteString)!],
           let progressBlock = download.progressClosure {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation({
                progressBlock(progress)
            })
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let error = error {
            let downloadTask = task as! URLSessionDownloadTask
            let key = (downloadTask.originalRequest?.url?.absoluteString)!
            if let download = self.ongoingDownloads[key] {
                OperationQueue.main.addOperation({
                    download.completionClosure(error, nil)
                })
            }
            self.ongoingDownloads.removeValue(forKey: key)
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if let completion = self.backgroundCompletionHandler {
                completion()
            }
            
            if self.showLocalNotificationOnBackgroundDownloadDone {
                var notificationText = "Download completed"
                if let userNotificationText = self.localNotificationText {
                    notificationText = userNotificationText
                }
                self.showLocalNotification(with: notificationText)
            }
            self.backgroundCompletionHandler = nil
        }
    }
}
