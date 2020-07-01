//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 16/01/20.
//

import Foundation
import UIKit

enum CommunityServiceApi {
    case getHomeData(params : [String : Any])
}

extension CommunityServiceApi: EndPointType {
    var isAuthorization: Bool {
        return false
    }

    var headers: HTTPHeaders? {
        return nil
    }
    
    public var baseURL: URL {
        guard let url = URL(string: "https://5e99a9b1bc561b0016af3540.mockapi.io/jet2/api/v1/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    public var path: String {
        switch self {
        case .getHomeData:
            return "blogs"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .getHomeData:
            return .get
        }
    }

    
    public var timeout: TimeInterval {
        return 60
    }
    
    
    public var task: HTTPTask {
        switch self {

        case .getHomeData(let param):
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: param,
                                                additionHeaders: headers)

        }
    }
}

