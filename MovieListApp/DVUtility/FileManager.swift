//
//  FileManager.swift
//  
//
//  Created by Apple on 05/06/20.
//

import Foundation
import UIKit


public struct AppFileManager {
  
  public init() { }
  
  public static let fileManager = FileManager.default
  public static var documentDirectory: URL? {
    return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
  public static let documentDirectoryURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
  
  
  public static func getDBPath(feature: String) -> String {
    return documentDirectory?.appendingPathComponent(feature).path ?? ""
  }
  
  public static func getFileUrl(filePath: String) -> URL? {
    return documentDirectoryURL.appendingPathComponent(filePath)
  }
  
  public static func getFilePath(filePath: String) -> URL? {
    return documentDirectory?.appendingPathComponent(filePath)
  }
  
  public static func getImageFromDirectory(_ filePath:String, defaultImage: String? = nil) -> UIImage? {
    if let filePath = documentDirectory?.appendingPathComponent(filePath).path {
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: filePath) {
        guard let image: UIImage = UIImage(contentsOfFile: filePath) else {
          if defaultImage != nil {
            return UIImage(named: defaultImage!)!
          }
          return nil
        }
        return image
      } else {
        //if defaultImage.count > 0 {
        if defaultImage != nil {
          if let image = UIImage(named: defaultImage!) {
            return image
          }
        }
      }
    }
    return  nil
    
  }
  
  // MARK: - Func to Delete file from directory
  public static func deleteFile(path: URL) {
      do {
        try fileManager.removeItem(at: path)
      } catch {
      }
  }
  
  // MARK: - Func to check file exist or not on directory
  public static func fileExists(_ fileName: String) -> String? {
    let filePath = documentDirectoryURL.appendingPathComponent(fileName).path
    if fileManager.fileExists(atPath: filePath) {
      return filePath
    }
    return nil
  }
  
  public static func createDirectorywith(folderName: String, isDirectory: Bool = false, intermediateDirectories:Bool =  true) {
    do {
      try fileManager.createDirectory(at: documentDirectoryURL.appendingPathComponent(folderName, isDirectory: isDirectory), withIntermediateDirectories: intermediateDirectories, attributes: nil)
    } catch {
    }
  }
  
  public static func saveImageDocument(filename: String, image: UIImage, imageType: String) {
    if let filePath = getFilePath(filePath: filename) {
      var isDir : ObjCBool = false
      if !fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir) {
        createDirectorywith(folderName: imageType, isDirectory: true, intermediateDirectories: true)
      }
      if !(fileExists(filePath.path) != nil) {
        if let data = image.pngData() { //Set image quality here
          do {
            try data.write(to: filePath)
          } catch {
          }
        }
      }
    }
  }
  
  public static func saveDocumentFromBundle(folderName:String, bundlePath: URL, filePath: String) {
    
    if let fileUrl = getFileUrl(filePath: filePath) {
        createDirectorywith(folderName: folderName, isDirectory: true, intermediateDirectories: true)
      deleteFile(path: fileUrl)
      do {
        try fileManager.copyItem(at: bundlePath, to: fileUrl)
      } catch {
      }
    }
  }
}
