//
//   Storage.swift
//
//
//  Created by Vaib  on 03/11/18.
//  Copyright © 2018 Piyush. All rights reserved.
//

import Foundation

public struct Storage {
    public enum Directory {
        // Only documents and other data that is user-generated,
        //or that cannot otherwise be recreated by your application,
        //should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        
        // Data that can be downloaded again or regenerated should be stored
        //in the <Application_Home>/Library/Caches directory.
        //Examples of files you should put in the Caches directory include
        //database cache files and downloadable content,
        //such as that used by magazine, newspaper, and map applications.
        case caches
    }
    
    /// Returns URL constructed from specified directory
    fileprivate static func getURL(for directory: Directory) -> URL? {
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            return nil
        }
    }
    
    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    public static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: true)  else {
            return
        }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
          print("store:\(error)")
        }
    }
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    public static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false)  else {
            return nil
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Remove all files at specified directory
    public static func clear(_ directory: Directory) {
        guard let url = getURL(for: directory)  else {
            return
        }
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url,
                                                                       includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
        }
    }
    
    /// Remove specified file from specified directory
    public static func remove(_ fileName: String, from directory: Directory) {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false)  else {
            return
        }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    public static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        guard let url = getURL(for: directory)?.appendingPathComponent(fileName, isDirectory: false)  else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
