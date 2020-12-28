//
//  XmlDocument.swift
//  SwiftXml
//
//  Created by Piotr Brzeski on 2020-12-27.
//

import SwiftUI
import UniformTypeIdentifiers

struct XmlDocument: FileDocument {
  static let contentType = UTType.xml
  static let readableContentTypes = [contentType]
  let xml: XmlNode
  
  init(xml: XmlNode) {
    self.xml = xml
  }
  
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw XmlError.parserError(message: "Can not get file data")
    }
    // TODO: XmlLoader.load(data)
    guard let string = String(data: data, encoding: .utf8) else {
      throw XmlError.parserError(message: "Can not get file data")
    }
    try self.xml = XmlLoader().load(string: string)
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    guard let data = xml.asXmlString.data(using: .utf8) else {
      throw XmlError.parserError(message: "Can not get XML data")
    }
    return FileWrapper(regularFileWithContents: data)
  }
}
