//
//  HTTPTask.swift
//  APIManager
//
//  Created by Vaibhav Jain on 02/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
public typealias HTTPHeaders = [String:String]

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case requestEncodable(bodyParameters: AnyEncodable,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case upload(bodyParameters: Parameters?,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?,
        documents: [Document]?)
    
}
