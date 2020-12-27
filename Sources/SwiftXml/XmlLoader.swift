//
//  XmlLoader.swift
//  SwiftXml
//
//  Created by Piotr Brzeski on 2020-07-19.
//

import Foundation

public class XmlLoader: NSObject, XMLParserDelegate {
  var nodes = [XmlNode]()
  var error: XmlError?
  
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
  {
//    print(String(repeating: " ", count: 2*self.nodes.count) + "<" + elementName + ">")
    do {
      var node = try XmlNode(elementName)
      for (name, value) in attributeDict {
        try node.set(attribute: name, value: value)
      }
      self.nodes.append(node)
    }
    catch let error as XmlError {
      self.error = error
    }
    catch {
      assert(false)
      self.error = XmlError.parserError(message: "Unknown error")
    }
  }
  
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard self.error == nil else {
      return
    }
    guard !self.nodes.isEmpty else {
      self.error = .parserError(message: "Set value - missing node")
      return
    }
    var node = self.nodes.popLast()!
    if node.value == nil {
      node.value = string
    }
    else {
      node.value! += string
    }
    self.nodes.append(node)
  }
  
  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//    print(String(repeating: " ", count: 2*(self.nodes.count - 1)) + "</" + elementName + ">")
    guard self.error == nil else {
      return
    }
    switch self.nodes.count {
    case 0:
      self.error = .parserError(message: "End element - missing node")
    case 1:
      break
    default:
      let subnode = self.nodes.popLast()!
      var node = self.nodes.popLast()!
      node.add(subnode)
      self.nodes.append(node)
    }
  }
  
  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    guard self.error == nil else {
      return
    }
    self.error = .parserError(message: parseError.localizedDescription)
  }
  
  public func load(url: URL) throws -> XmlNode {
    guard let parser = XMLParser(contentsOf: url) else {
      throw XmlError.parserError(message: "Can not create XML parser for URL \"" + url.absoluteString + "\"")
    }
    return try self.parse(parser: parser)
  }
  
  public func load(string: String) throws -> XmlNode {
    let data: Data = string.data(using: .utf8)!
    let parser = XMLParser(data: data)
    return try self.parse(parser: parser)
  }
  
  private func parse(parser: XMLParser) throws -> XmlNode {
    parser.delegate = self
    let result = parser.parse()
    if let error = self.error {
      throw error
    }
    assert(result)
    guard result && self.nodes.count == 1 else {
      throw XmlError.parserError(message: "Invalid number of root nodes - \(self.nodes.count)")
    }
    return self.nodes.popLast()!
  }
}
