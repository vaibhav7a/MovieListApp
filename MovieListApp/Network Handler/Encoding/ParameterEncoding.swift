//
//  ParameterEncoding.swift
//  APIManager
//
//  Created by Vaibhav Jain on 02/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters, documents: [Document]?) throws
}

public enum ParameterEncoding {
    
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    case uploadDocumentEncoding
    
    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?,
                       documents: [Document]? = nil) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .urlAndJsonEncoding:
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .uploadDocumentEncoding:
                 try UploadEncoder().encode(urlRequest: &urlRequest, with: bodyParameters ?? Parameters(), documents: documents)
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                
            }
        }catch {
            throw error
        }
    }
}


public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
