// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


/**
 Settings can be specified as either key:value, or key:list-of-values.
 
 To allow us to use Decodable for the overall configuration structure,
 this enumeration represents either, in a decodable way.
 
 If the json has a string, we end up with SettingsValue.string, if it
 has a list, we end up with SettingsValue.list.
 */

enum SettingsValue : Equatable, Decodable, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
    case string(String)
    case list([String])
    
    init(from decoder: Decoder) throws {
        if var container = try? decoder.unkeyedContainer() {
            var value: [String] = []
            while !container.isAtEnd {
                if let v = try? container.decode(String.self) {
                    value.append(v)
                }
            }
            self = .list(value)
        } else {
            let container = try decoder.singleValueContainer()
            self = .string(try container.decode(String.self))
        }
    }
    
    init(stringLiteral: String) {
        self = .string(stringLiteral)
    }
    
    init(arrayLiteral elements: String...) {
        self = .list(elements)
    }

    func stringValue() -> String {
        if case let .string(s) = self {
            return s
        }
        
        return ""
    }
    
    func listValue() -> [String] {
        if case let .list(l) = self {
            return l
        } else if case let .string(s) = self {
            return [s]
        }
        
        return []
    }

}
