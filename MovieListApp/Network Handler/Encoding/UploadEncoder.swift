//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 27/02/20.
//

import Foundation
public struct UploadEncoder: ParameterEncoder {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters, documents: [Document]? = nil) throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let jsonAsData = prepareMultipartData(parameters: parameters, documents: documents, boundary: boundary)
        urlRequest.httpBody = jsonAsData
        
    }
    
    func prepareMultipartData(parameters: Parameters, documents: [Document]?, boundary: String) -> Data {
        let httpBody = NSMutableData()
        for (key, value) in parameters {
            httpBody.appendString(convertFormField(named: key, value: "\(value)", using: boundary))
        }
        
        if let documents = documents {
            for document in documents {
                httpBody.append(convertFileData(fieldName: document.key ?? document.name.fileName(),
                                                fileName: document.name,
                                                mimeType: document.mimeType,
                                                fileData: document.document,
                                                using: boundary))
            }
            
        }
        httpBody.appendString("--\(boundary)--\r\n")
        return httpBody as Data
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
           var fieldString = "--\(boundary)\r\n"
           fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
           fieldString += "\r\n"
           fieldString += "\(value)\r\n"
           return fieldString
       }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        return data as Data
    }
}

fileprivate extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

fileprivate extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
