//
//  XmlTests.swift
//  XmlTests
//
//  Created by Piotr Brzeski on 14/07/2020.
//

import SwiftXml
import XCTest

class SwiftXmlTests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testXmlNodeAsString() throws {
    let attrs1 = "attr1=\"val1\" attr2=\"val2\""
    let attrs2 = "attr2=\"val2\" attr1=\"val1\""
    var node = try XmlNode("node")
    XCTAssertEqual(node.asString, "<node/>")
    node.value = "value"
    XCTAssertEqual(node.asString, "<node>value</node>")
    try node.set(attribute: "attr1", value: "val1")
    XCTAssertEqual(node.asString, "<node attr1=\"val1\">value</node>")
    try node.set(attribute: "attr2", value: "val2")
    XCTAssert(node.asString == "<node " + attrs1 + ">value</node>" || node.asString == "<node " + attrs2 + ">value</node>")
    node.value = nil
    XCTAssert(node.asString == "<node " + attrs1 + "/>" || node.asString == "<node " + attrs2 + "/>")
    node.remove(attribute: "attr2")
    XCTAssertEqual(node.asString, "<node attr1=\"val1\"/>")
    var root = try XmlNode("root")
    root.subnodes.append(node)
    XCTAssertEqual(root.asString, "<root><node attr1=\"val1\"/></root>")
    root.subnodes.append(node)
    XCTAssertEqual(root.asString, "<root><node attr1=\"val1\"/><node attr1=\"val1\"/></root>")
  }

  func testXmlNameValidation() throws {
    var node = try XmlNode("node")
    _ = try XmlNode("Node")
    _ = try XmlNode("Node-1")
    _ = try XmlNode("Node_2")
    _ = try XmlNode("X___")
    _ = try XmlNode("namespace:name")
    XCTAssertThrowsError(try XmlNode(""), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    XCTAssertThrowsError(try XmlNode("_node"), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    XCTAssertThrowsError(try XmlNode("1node"), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    XCTAssertThrowsError(try XmlNode("-node"), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    XCTAssertThrowsError(try XmlNode("node name"), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    XCTAssertThrowsError(try XmlNode("node&node"), "Invalid node name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidNodeName) }
    
    XCTAssertThrowsError(try node.set(attribute: "", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "_node", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "1node", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "-node", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "node name", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "node&node", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: ":abc", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "abc:", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    XCTAssertThrowsError(try node.set(attribute: "a:b:c", value: "x"), "Invalid attribute name should throw") { error in XCTAssertEqual(error as? XmlError, XmlError.invalidAttributeName) }
    try node.set(attribute: "attribute", value: "x")
    try node.set(attribute: "Attribute", value: "x")
    try node.set(attribute: "attribute-1", value: "x")
    try node.set(attribute: "attribute_2", value: "x")
    try node.set(attribute: "A___", value: "x")
  }
  
  func testXmlEscaping() throws {
    var node = try XmlNode("node")
    node.value = "a & b"
    XCTAssertEqual(node.asString, "<node>a &amp; b</node>")
    node.value = "<ab>"
    XCTAssertEqual(node.asString, "<node>&lt;ab&gt;</node>")
    node.value = "\""
    XCTAssertEqual(node.asString, "<node>\"</node>")
    node.value = "'"
    XCTAssertEqual(node.asString, "<node>'</node>")
    node.value = nil
    try node.set(attribute: "a", value: "a & b")
    XCTAssertEqual(node.asString, "<node a=\"a &amp; b\"/>")
    try node.set(attribute: "a", value: "<ab>")
    XCTAssertEqual(node.asString, "<node a=\"&lt;ab&gt;\"/>")
    try node.set(attribute: "a", value: "\"")
    XCTAssertEqual(node.asString, "<node a=\"&quot;\"/>")
    try node.set(attribute: "a", value: "'")
    XCTAssertEqual(node.asString, "<node a=\"'\"/>")
  }

//  func testPerformanceExample() throws {
//    // This is an example of a performance test case.
//    measure {
//      // Put the code you want to measure the time of here.
//    }
//  }
  
}
