//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 27/02/20.
//

import Foundation

public struct Document {
    public let document: Data
    public let name: String
    public let key: String?
    public let mimeType: String
    public init (document: Data, key: String? = nil, name: String, mimeType: String? =  nil) {
        self.document = document
        self.name = name
        self.key = key
        self.mimeType = mimeType ?? MimeType(path: name).value
    }
}

