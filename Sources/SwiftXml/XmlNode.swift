//
//  XmlNode.swift
//  SwiftXml
//
//  Created by Piotr Brzeski on 2020-07-14.
//

import SwiftTypes
import Foundation

public enum XmlError: Error, Equatable {
  case invalidNodeName
  case invalidAttributeName
  case invalidStructure
  case parserError(message: String)
}

public struct XmlNode {
  public var value: String?
  public var subnodes = [XmlNode]()
  
  public private(set) var name: String
  private var _attributes = [String:String]()
  
  public init(_ name: String) throws {
    guard XmlNode.validate(name: name) else {
      throw XmlError.invalidNodeName
    }
    self.name = name
  }
  
  public mutating func set(attribute: String, value: String) throws {
    guard XmlNode.validate(name: attribute) else {
      throw XmlError.invalidAttributeName
    }
    self._attributes[attribute] = value
  }
  
  public mutating func set(attribute: String, value: Int) throws {
    try set(attribute: attribute, value: String(value))
  }
  
  public mutating func set(attribute: String, value: Double, precision: Int = 2) throws {
    try set(attribute: attribute, value: value.string(precision: precision))
  }
  
  public mutating func set(attribute: String, value: Bool) throws {
    try set(attribute: attribute, value: value ? "1" : "0")
  }
  
  public mutating func set(attribute: String, value: Date) throws {
    try set(attribute: attribute, value: value.dateString)
  }
  
  public mutating func remove(attribute: String) {
    self._attributes.removeValue(forKey: attribute)
  }
  
  public var attributes: [String:String] {
    self._attributes
  }
  
  public func attribute(_ name: String) throws -> String {
    guard let value = self.attributes[name] else {
      throw XmlError.invalidStructure
    }
    return value
  }
  
  public func int(fromAttribute name: String) throws -> Int {
    let value = try self.attribute(name)
    guard let number = Int(value) else {
      throw XmlError.invalidStructure
    }
    return number
  }
  
  public func double(fromAttribute name: String) throws -> Double {
    let value = try self.attribute(name)
    guard let number = Double(value) else {
      throw XmlError.invalidStructure
    }
    return number
  }
  
  public func bool(fromAttribute name: String) throws -> Bool {
    let value = try self.attribute(name)
    guard let number = Int(value) else {
      throw XmlError.invalidStructure
    }
    switch number {
    case 0:
      return false
    case 1:
      return true
    default:
      throw XmlError.invalidStructure
    }
  }
  
  public func date(fromAttribute name: String) throws -> Date {
    guard let dateString = self.attributes[name] else {
      throw XmlError.invalidStructure
    }
    guard let date = Date.from(dateString: dateString) else {
      throw XmlError.invalidStructure
    }
    return date
  }
  
  public mutating func add(_ node: XmlNode) {
    self.subnodes.append(node)
  }
  
  public func child(_ name: String) throws -> XmlNode {
    guard let node = self.subnodes.first(where: {$0.name == name}) else {
      throw XmlError.invalidStructure
    }
    return node
  }
  
  public func children(where predicate: (XmlNode)->Bool) -> [XmlNode] {
    var children = [XmlNode]()
    for node in self.subnodes {
      if predicate(node) {
        children.append(node)
      }
    }
    return children
  }
  
  public var asString: String {
    var str = "<" + self.name
    for (name, value) in self._attributes {
      str += " " + name + "=\"" + escape(attribute: value) + "\""
    }
    var close_using_tag = false
    if let value = self.value {
      str += ">" + escape(value: value)
      close_using_tag = true
    }
    if !subnodes.isEmpty {
      if !close_using_tag {
        str += ">"
        close_using_tag = true
      }
      for subnode in self.subnodes {
        str += subnode.asString
      }
    }
    if close_using_tag {
      str += "</" + self.name + ">"
    }
    else {
      str += "/>"
    }
    return str
  }
  
  public func asFormattedString(level: Int) -> String {
    var str = String(repeating: "  ", count: level) + "<" + self.name
    for (name, value) in self._attributes {
      str += " " + name + "=\"" + escape(attribute: value) + "\""
    }
    var close_using_tag = false
    if let value = self.value {
      str += ">" + escape(value: value)
      close_using_tag = true
    }
    if !subnodes.isEmpty {
      if !close_using_tag {
        str += ">\n"
        close_using_tag = true
      }
      for subnode in self.subnodes {
        str += subnode.asFormattedString(level: level + 1)
      }
      str += String(repeating: "  ", count: level)
    }
    if close_using_tag {
      str += "</" + self.name + ">" + "\n"
    }
    else {
      str += "/>\n"
    }
    return str
  }
  
  public var asXmlString: String {
    let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    return xml + self.asString
  }
  
  public var asFormattedXmlString: String {
    let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    return xml + self.asFormattedString(level: 0)
  }
  
  // MARK: - Private
  private func escape(value: String) -> String {
    return value
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "<", with: "&lt;")
      .replacingOccurrences(of: ">", with: "&gt;")
  }
  
  private func escape(attribute: String) -> String {
    return escape(value: attribute)
      .replacingOccurrences(of: "\"", with: "&quot;")
  }
  
  private static func validate(name: String) -> Bool {
    let components = name.split(separator: ":", omittingEmptySubsequences: false)
    return components.count < 3 && components.reduce(true) { $0 && validate(substring: $1) }
  }
    
  private static func validate(substring: Substring) -> Bool {
    let pattern = "[a-zA-Z][a-zA-Z0-9_-]*"
    if let range = substring.range(of: pattern, options: .regularExpression) {
        return substring[range].count == substring.count
    }
    return false
  }
}
