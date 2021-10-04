//
//  CSSParser.swift
//  Macaw
//
//  Created by Yuri Strot on 10/26/18.
//

import Foundation

#if !CARTHAGE
import SWXMLHash
#endif

enum Selector {
    case byId(String)
    case byClass(String)
    case byTag(String)
}

class CSSParser {

    fileprivate var stylesByClass: [String: [String: String]] = [:]
    fileprivate var stylesById: [String: [String: String]] = [:]
    fileprivate var stylesByTag: [String: [String: String]] = [:]

    func parse(content: String) {
        let parts = content.components(separatedBy: .whitespacesAndNewlines).joined().split(separator: "{")

        var separatedParts = [String.SubSequence]()

        parts.forEach { substring in
            separatedParts.append(contentsOf: substring.split(separator: "}"))
        }

        if separatedParts.count % 2 == 0 {

            let headers = stride(from: 0, to: separatedParts.count, by: 2).map { String(separatedParts[$0]) }
            let bodies = stride(from: 1, to: separatedParts.count, by: 2).map { separatedParts[$0] }

            for (index, header) in headers.enumerated() {
                for headerPart in header.split(separator: ",") where headerPart.count > 1 {
                    let selector = parseSelector(text: String(headerPart))
                    var currentStyles = getStyles(selector: selector)
                    if currentStyles == nil {
                        currentStyles = [String: String]()
                    }
                    let style = String(bodies[index])
                    let styleParts = style.components(separatedBy: ";")
                    styleParts.forEach { styleAttribute in
                        if !styleAttribute.isEmpty {
                            let currentStyle = styleAttribute.components(separatedBy: ":")
                            if currentStyle.count == 2 {
                                currentStyles![currentStyle[0]] = currentStyle[1]
                            }
                        }
                    }
                    setStyles(selector: selector, styles: currentStyles!)
                }
            }
        }
    }

    func parseSelector(text: String) -> Selector {
        if text.first == "#" {
            return .byId(String(text.dropFirst()))
        } else if text.first == "." {
            return .byClass(String(text.dropFirst()))
        }
        return .byTag(text)
    }

    func getStyles(element: XMLHash.XMLElement) -> [String: String] {
        var styleAttributes = [String: String]()

        if let styles = stylesByTag[element.name] {
            for (att, val) in styles {
                if styleAttributes.index(forKey: att) == nil {
                    styleAttributes.updateValue(val, forKey: att)
                }
            }
        }

        if let classNamesString = element.allAttributes["class"]?.text {
            let classNames = classNamesString.split(separator: " ")

            classNames.forEach { className in
                let classString = String(className)

                if let styleAttributesFromTable = stylesByClass[classString] {
                    for (att, val) in styleAttributesFromTable {
                        if styleAttributes.index(forKey: att) == nil {
                            styleAttributes.updateValue(val, forKey: att)
                        }
                    }
                }
            }
        }

        if let idString = element.allAttributes["id"]?.text {
            if let styleAttributesFromTable = stylesById[idString] {
                for (att, val) in styleAttributesFromTable {
                    if styleAttributes.index(forKey: att) == nil {
                        styleAttributes.updateValue(val, forKey: att)
                    }
                }
            }
        }

        return styleAttributes
    }

    fileprivate func getStyles(selector: Selector) -> [String: String]? {
        switch selector {
        case .byId(let id):
            return stylesById[id]
        case .byTag(let tag):
            return stylesByTag[tag]
        case .byClass(let name):
            return stylesByClass[name]
        }
    }

    fileprivate func setStyles(selector: Selector, styles: [String: String]) {
        switch selector {
        case .byId(let id):
            stylesById[id] = styles
        case .byTag(let tag):
            stylesByTag[tag] = styles
        case .byClass(let name):
            stylesByClass[name] = styles
        }
    }

}
