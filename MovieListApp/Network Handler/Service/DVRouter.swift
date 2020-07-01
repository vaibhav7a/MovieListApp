//
//  Router.swift
//  APIManager
//
//  Created by Vaibhav Jain on 02/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    case authenticationError
    case badRequest
    case outdated
    case failed
    case inValidToken
    case networkNotReachable
    public var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .authenticationError: return "You need to be authenticated first"
        case .badRequest: return "Bad request"
        case .outdated: return "The url you requested is outdated"
        case .failed: return "Network request failed"
        case .inValidToken: return "The access token provided has expired/not-valid"
        case .networkNotReachable: return "Network not reachable"
        }
    }
}


public enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}


typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void

public protocol NetworkRouter {
    associatedtype EndPoint: EndPointType
    func fetch<T: Decodable>(_ route: EndPoint, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
}

public class Router<EndPoint: EndPointType>: NetworkRouter {
    
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    var shouldRetry = true
    public init() {}
    fileprivate func excuteTaks(with request: URLRequest,completionHandler completion: @escaping ([[String: Any]]?, APIError?) -> Void) -> URLSessionDataTask{
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            NetworkLogger.log(response: response ?? httpResponse)
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(nil, .invalidData)
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]{
                        completion(json, nil)
                    }
//                    let genericModel = try JSONDecoder().decode(decodingType, from: data)
//                    completion(genericModel, nil)
                } catch {
                    completion(nil, .jsonConversionFailure)
                }
            case 401:
                completion(nil, .inValidToken)
                return
            case 402...500:
                completion(nil, .authenticationError)
                return
            case 400,501...599:
                completion(nil, .badRequest)
                return
            case 600:
                completion(nil, .outdated)
                return
            default:
                completion(nil, .failed)
                return
            }
        }
        return task
    }
    //for codable
    fileprivate func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            NetworkLogger.log(response: response ?? httpResponse)
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(nil, .invalidData)
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]{

                    }
                    let genericModel = try JSONDecoder().decode(decodingType, from: data)
                    completion(genericModel, nil)
                } catch {
                    completion(nil, .jsonConversionFailure)
                }
            case 401:
                completion(nil, .inValidToken)
                return
            case 402...500:
                completion(nil, .authenticationError)
                return
            case 400,501...599:
                completion(nil, .badRequest)
                return
            case 600:
                completion(nil, .outdated)
                return
            default:
                completion(nil, .failed)
                return
            }
        }
        return task
    }

    public func fetchRequest(_ route: EndPoint, completion: @escaping ([[String: Any]]?, APIError?) -> Void) {
        if !Utility.isNetworkAvailable {
            completion(nil, .networkNotReachable)
            return
        }
        let accessToken = UserDefaults.standard.string(forKey: "AccessToken")
        if  accessToken != nil || !route.isAuthorization {
            do {
                let request = try self.buildRequest(from: route, accessToken: accessToken)
                NetworkLogger.log(request: request)
                let task = excuteTaks(with: request) { (json , error) in

                    //MARK: change to main queue
                    DispatchQueue.main.async {
                        guard let json = json else {
                            if let error = error {
                                if error == .inValidToken, self.shouldRetry, route.isAuthorization {
                                    self.shouldRetry = false
                                    self.generateToken { (error) in
                                        if let error = error {
                                            completion(nil, error)
                                        } else {
                                            self.fetchRequest(route,completion: completion)
                                        }
                                    }
                                } else {
                                    completion(nil, error)
                                }
                            } else {
                                completion(nil, .invalidData)
                            }
                            return
                        }
                        completion(json, nil)
                    }}
                task.resume()

            } catch {
                completion(nil, .jsonParsingFailure)
            }
        } else {
            self.generateToken { (error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    self.fetchRequest(route,completion: completion)
                }
            }
        }
    }
    public func fetch<T: Decodable>(_ route: EndPoint, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        if !Utility.isNetworkAvailable {
            completion(Result.failure(.networkNotReachable))
            return
        }
        let accessToken = UserDefaults.standard.string(forKey: "AccessToken")
        if  accessToken != nil || !route.isAuthorization {
            do {
                let request = try self.buildRequest(from: route, accessToken: accessToken)
                NetworkLogger.log(request: request)
                let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
                    
                    //MARK: change to main queue
                    DispatchQueue.main.async {
                        guard let json = json else {
                            if let error = error {
                                if error == .inValidToken, self.shouldRetry, route.isAuthorization {
                                    self.shouldRetry = false
                                    self.generateToken { (error) in
                                        if let error = error {
                                            completion(Result.failure(error))
                                        } else {
                                            self.fetch(route, decode: decode, completion: completion)
                                        }
                                    }
                                } else {
                                    completion(Result.failure(error))
                                }
                            } else {
                                completion(Result.failure(.invalidData))
                            }
                            return
                        }
                        if let value = decode(json) {
                            completion(.success(value))
                        } else {
                            completion(.failure(.jsonParsingFailure))
                        }
                    }}
                task.resume()
                
            } catch {
                completion(.failure(.jsonParsingFailure))
            }
        } else {
            self.generateToken { (error) in
                if let error = error {
                    completion(Result.failure(error))
                } else {
                    self.fetch(route, decode: decode, completion: completion)
                }
            }
        }
    }
    
    fileprivate func generateToken(completion: @escaping (APIError?) -> Void) {
        switch NetworkManager.authGrantType {
        case .clientCredentials:
            NetworkManager.generateToken(completion: { result in
                switch result {
                case .success(let tokenResponse):
                    guard let accessToken = tokenResponse?.data.accessToken else {
                        completion(.inValidToken)
                        return
                    }
                    UserDefaults.standard.set(accessToken, forKey: "AccessToken")
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
        case .passwordGrant:
            NetworkManager.refreshToken(completion: { result in
                switch result {
                case .success(let tokenResponse):
                    guard let accessToken = tokenResponse?.data.accessToken, let refreshToken = tokenResponse?.data.refreshToken else {
                        completion(.inValidToken)
                        return
                    }
                    UserDefaults.standard.set(accessToken, forKey: "AccessToken")
                    UserDefaults.standard.setValue(accessToken, forKey: "AuthApi_clientID")
                    UserDefaults.standard.setValue(refreshToken, forKey: "AuthApi_clientSecret")
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            })
        }
    }
    
    fileprivate func buildRequest(from route: EndPoint, accessToken: String?) throws -> URLRequest {
        
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: route.timeout)
        
        request.httpMethod = route.httpMethod.rawValue
        if let accessToken = accessToken, route.isAuthorization {
            request.setValue(accessToken, forHTTPHeaderField: "Access-Token")
        }
        addAdditionalHeaders(route.headers, request: &request)

        do {
            switch route.task {
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
              
            case .requestEncodable(let bodyParameters,
                                   let urlParameters,
                                   let additionHeaders):
              
              try configureParameters(bodyParameters: bodyParameters, request: &request)
              
              try configureParameters(bodyParameters: nil,
                                           bodyEncoding: .urlEncoding,
                                           urlParameters: urlParameters,
                                           request: &request)
              
              addAdditionalHeaders(additionHeaders, request: &request)

            case .request:
                break
            case .upload(let bodyParameters, let urlParameters, let additionHeaders, let documents):
               
                try configureParameters(bodyParameters: bodyParameters,
                                        bodyEncoding: .uploadDocumentEncoding,
                                        documents: documents,
                                        urlParameters: urlParameters,
                                        request: &request)
                
                addAdditionalHeaders(additionHeaders, request: &request)

            }
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/vnd.Apple.v1+json", forHTTPHeaderField: "Content-Type")
            }
            
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
  
  fileprivate func configureParameters(bodyParameters: AnyEncodable,
                                       request: inout URLRequest) throws {
      do {
          let jsonEncoder = JSONEncoder()
          let jsonData = try jsonEncoder.encode(bodyParameters)
          request.httpBody = jsonData
      } catch {
          throw error
      }
  }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         documents: [Document]?,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
do {
    try bodyEncoding.encode(urlRequest: &request,
                            bodyParameters: bodyParameters, urlParameters: urlParameters, documents: documents)
} catch {
    throw error
}
     }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}


public struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

  public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
