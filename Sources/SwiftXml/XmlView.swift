//
//  SwiftUIView.swift
//  SwiftXml
//
//  Created by Piotr Brzeski on 2020-12-26.
//

import SwiftUI

public struct XmlView: View {
  private let xml: XmlNode
  @State private var subnodesVisible = true
  
  public init(xml: XmlNode) {
    self.xml = xml
  }
  
  public var body: some View {
    HStack(alignment: .top, spacing: 0) {
        Image(systemName: self.xml.subnodes.isEmpty ? "circle" : self.subnodesVisible ? "chevron.down.circle" : "chevron.forward.circle")
          .opacity(self.xml.subnodes.isEmpty ? 0.1 : 0.8)
          .onTapGesture { self.subnodesVisible.toggle() }
      VStack(alignment: .leading) {
        HStack(alignment: .top, spacing: 0) {
          self.value
            .padding(.leading, 8.0)
          self.attributes
        }
        if self.subnodesVisible {
          self.subnodes
        }
      }
    }
  }
  
  private var value: some View {
    var valueString = self.xml.name
    if let nodeValue = self.xml.value {
      valueString += "=\"" + nodeValue + "\""
    }
    return Text(valueString)
  }
  
  private var attributes: some View {
    var attributesString = ""
    for attribute in self.xml.attributes {
      if !attributesString.isEmpty {
        attributesString.append(" ")
      }
      attributesString.append(attribute.key + "=\"" + attribute.value + "\"")
    }
    return Text(attributesString).multilineTextAlignment(.leading)
  }
  
  private var subnodes: some View {
    ForEach(self.xml.subnodes.indices, id: \.self) { index in
      XmlView(xml: self.xml.subnodes[index])
    }
  }
}

struct XmlView_Previews: PreviewProvider {
  static func singleNode() -> XmlNode {
    var node = try! XmlNode("node")
    try! node.set(attribute: "Attribute", value: "Value")
    try! node.set(attribute: "Number", value: 17)
    return node
  }
  static func testNode() -> XmlNode {
    var node = singleNode()
    node.add(singleNode())
    node.add(singleNode())
    var subnode = singleNode()
    subnode.add(singleNode())
    subnode.add(singleNode())
    node.value = "Test value"
    node.add(subnode)
    return node
  }
  static var previews: some View {
    VStack {
      HStack {
        XmlView(xml: testNode())
        Spacer()
      }
      Spacer()
    }
  }
}
