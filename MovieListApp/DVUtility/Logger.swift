//
//  Logger.swift
//  Apple5
//
//  Created by Vaibhav  on 11/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

// Enum for showing the type of Log Types
 public enum LogEvent: Int {
    case error
    case info
    case debug
    case verbose
    case warning
    case severe
    
   var description: String {
        switch self {
        case .error:
            return "[‼️]"
        case .info:
             return "[ℹ️]"
        case .debug:
             return "[💬]"
        case .verbose:
             return "[🔬]"
        case .warning:
             return "[⚠️]"
        case .severe:
             return "[🔥]"
    }
    }
}

public class Logger {
    
    public class var targetLogEvent: [LogEvent] {
        get {
            guard let eventArray = UserDefaults.standard.value(forKey: "targetLogEvent") as? [Int] else {
                return []
            }
            let values: [LogEvent] = eventArray.map { (LogEvent(rawValue: $0) ?? LogEvent.debug) }
            return values
        }
        set (eventArray){
            let values: [Int] = eventArray.map { $0.rawValue }
            UserDefaults.standard.setValue(values, forKey: "targetLogEvent")
        }
    }
    public class var enableLogging: Bool {
        get {
            let enableLogging = UserDefaults.standard.bool(forKey: "enbaleLogging")
            return enableLogging
        } set{
            UserDefaults.standard.setValue(newValue, forKey: "enbaleLogging")
        }
    }
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public class func log(message: Any...,
                   event: LogEvent,
                   fileName: String = #file,
                   line: Int = #line,
                   column: Int = #column,
                   funcName: String = #function) {
        
        if enableLogging, targetLogEvent.contains(event) {
             print("\(Date().toString()) \(event.description)[\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
        }
    }
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
