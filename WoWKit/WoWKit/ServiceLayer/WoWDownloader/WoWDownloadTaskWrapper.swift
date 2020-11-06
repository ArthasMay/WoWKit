//
//  backgroundSession.swift
//  WoWKit
//  URLSession
//  Created by Silence on 2020/11/5.
//

import Foundation

class WoWDownloadTaskWrapper {
    var completionClosure: WoWDownloader.DownloadCompletionClosure
    var progressClosure: WoWDownloader.DownloadProgressClosure?
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName: String?
    
    init(downloadTask: URLSessionDownloadTask,
         progressClosure: WoWDownloader.DownloadProgressClosure?,
         completionClosure: @escaping WoWDownloader.DownloadCompletionClosure,
         fileName: String?,
         directoryName: String?) {
        self.downloadTask = downloadTask
        self.completionClosure = completionClosure
        self.progressClosure = progressClosure
        self.fileName = fileName
        self.directoryName = directoryName
    }
}
