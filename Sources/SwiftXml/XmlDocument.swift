//
//  XmlDocument.swift
//  SwiftXml
//
//  Created by Piotr Brzeski on 2020-12-27.
//

import SwiftUI
import UniformTypeIdentifiers

public struct XmlDocument: FileDocument {
  public static let contentType = UTType.xml
  public static let readableContentTypes = [contentType]
  let xml: XmlNode
  
  public init(xml: XmlNode) {
    self.xml = xml
  }
  
  public init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw XmlError.parserError(message: "Can not get file data")
    }
    try self.xml = XmlLoader().load(data: data)
  }
  
  public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    guard let data = xml.asXmlString.data(using: .utf8) else {
      throw XmlError.parserError(message: "Can not get XML data")
    }
    return FileWrapper(regularFileWithContents: data)
  }
}
