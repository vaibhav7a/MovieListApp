//
//  DownloadManager.swift
//  CommunityApp
//
//  Created by Vaibhav Jain on 05/02/20.
//  Copyright © 2020 Vaibhav Jain. All rights reserved.
//
import UIKit
import Foundation

typealias JSON = [String: Any]
private let imageCache = NSCache<NSString, UIImage>()

extension NSError {
    static func generalParsingError(domain: String) -> Error {
        return NSError(domain: domain, code: 400, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error retrieving data", comment: "General Parsing Error Description")])
    }
}

class ImageDownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    // MARK: - Public

    //static var shared = ImageDownloadManager()

    typealias ProgressHandler = (Float) -> Void

    var onProgress: ProgressHandler? {
        didSet {
            if onProgress != nil {
                _ = activate()
            }
        }
    }

    override private init() {
        super.init()
    }

    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")

        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }

    private func calculateProgress(session: URLSession, completionHandler : @escaping (Float) -> Void) {
        session.getTasksWithCompletionHandler { (_, _, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler(progress.reduce(0.0, +))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite > 0 {
            if let onProgress = onProgress {
                calculateProgress(session: session, completionHandler: onProgress)
            }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")

        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        try? FileManager.default.removeItem(at: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }

    static func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            ImageDownloadManager.downloadData(url: url) { data, _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }

                } else if let data = data, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, NSError.generalParsingError(domain: url.absoluteString))
                    }
                }
            }
        }
    }

    static func search(for query: String, page: Int, completion: @escaping (_ responseObject: [String: Any]?, _ error: Error?) -> Void) {
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "http://www.omdbapi.com/?s=\(encodedQuery)&page=\(page)") {
            ImageDownloadManager.downloadData(url: url) { data, _, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    if let data = data, let responseObject = self.convertToJSON(with: data) {
                        completion(responseObject, nil)
                    } else {
                        completion(nil, NSError.generalParsingError(domain: url.absoluteString))
                    }
                }
            }
        }
    }

    // MARK: - Private

    fileprivate static func downloadData(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession(configuration: .ephemeral).dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(data, response, error)
            }.resume()

    }

    fileprivate static func convertToJSON(with data: Data) -> JSON? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON
        } catch {
            return nil
        }
    }
}

//Usage in class
/*
 if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
     print("Cached image used, no need to download it")
     cell.imageView?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
 }else{
     // 3
     let artworkUrl = dictionary["artworkUrl100"] as! String
     let url:URL! = URL(string: artworkUrl)
     
     ImageDownloadManager.downloadImage(url: url) { (image, error) in
         DispatchQueue.main.async(execute: { () -> Void in
             if let updateCell = tableView.cellForRow(at: indexPath) {
                 updateCell.imageView?.image = image
                 self.cache.setObject(image!, forKey: (indexPath as NSIndexPath).row as AnyObject)
             }
         })
     }
 **/

//Usage of ProgressView (if we need to show progress bar with keep downloading images in background)
/*
 @IBOutlet weak var progressView: UIProgressView!
 
 override func viewDidLoad() {
     let _ = DownloadManager.shared.activate()
 }
 
 override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     DownloadManager.shared.onProgress = { (progress) in
         OperationQueue.main.addOperation {
             self.progressView.progress = progress
         }
     }
 }

 override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     DownloadManager.shared.onProgress = nil
 }
 
 @IBAction func startDownload(_ sender: Any) {
     //let url = URL(string: "https://scholar.princeton.edu/sites/default/files/oversize_pdf_test_0.pdf")!
     let array = ["https://picsum.photos/id/119/3264/2176","https://picsum.photos/id/062/4147/2756",
 "https://picsum.photos/id/119/3264/2176","https://picsum.photos/id/062/4147/2756"]
     
     for url in array{
         let task = DownloadManager.shared.activate().downloadTask(with: URL(string:url)!)
         task.resume()
     }
 }
 **/
