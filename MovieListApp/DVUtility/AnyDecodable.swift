//
//  AnyDecodable.swift
//  
//
//  Created by Apple on 05/02/20.
//

import Foundation

//MARK:- This Structure is using for Any format of JSON, It will return [String:Any]
public struct AnyDecodable: Decodable {
  public var value: Any

  private struct CodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(intValue: Int) {
      self.stringValue = "\(intValue)"
      self.intValue = intValue
    }
    init?(stringValue: String) { self.stringValue = stringValue }
  }

  public init(from decoder: Decoder) throws {
    if let container = try? decoder.container(keyedBy: CodingKeys.self) {
      var result = [String: Any]()
      try container.allKeys.forEach { (key) throws in
        result[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
      }
      value = result
    } else if var container = try? decoder.unkeyedContainer() {
      var result = [Any]()
      while !container.isAtEnd {
        result.append(try container.decode(AnyDecodable.self).value)
      }
      value = result
    } else if let container = try? decoder.singleValueContainer() {
      if let intVal = try? container.decode(Int.self) {
        value = intVal
      } else if let doubleVal = try? container.decode(Double.self) {
        value = doubleVal
      } else if let boolVal = try? container.decode(Bool.self) {
        value = boolVal
      } else if let stringVal = try? container.decode(String.self) {
        value = stringVal
      } else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable the container contains nothing serialisable")
      }
    } else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "AnyDecodable Could not serialise"))
    }
  }
}