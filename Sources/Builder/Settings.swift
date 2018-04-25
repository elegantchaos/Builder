// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Represents the settings section of a configuration.
 */

struct Settings : Decodable {
    typealias SettingList = [String]
    typealias SettingsDictionary = [String:SettingsValue]
    
    struct Inheritance : Decodable {
        let name : String
        let filter : [String]?
    }
    
    let values : SettingsDictionary?
    let inherits : [Inheritance]?
    
    func mappedSettings(for name: String, value: SettingsValue, mapping: [String:Any]) -> [String] {
        var result: [String] = []
        if let prefix = mapping["prefix"] as? [String] {
            result.append(contentsOf: prefix)
        }
        
        if let valueMappings = mapping["values"] as? [String:Any] {
            for value in value.listValue() {
                if let value = valueMappings[value] as? String {
                    result.append(value)
                } else if let values = valueMappings[value] as? [String] {
                    result.append(contentsOf: values)
                }
            }
        } else if let rawValues = mapping["rawValues"] as? [String] {
            var prefixValues = rawValues
            prefixValues.removeLast()
            if let lastValue = rawValues.last {
                for value in value.listValue() {
                    result.append(contentsOf: prefixValues)
                    result.append(lastValue.appending(value))
                }
            }
        }
        
        return result
    }
    
    func mappedSettings(for tool: String) -> [String] {
        var args : [String] = []
        
        if let values = values {
            for value in values {
                if let mapping = settingsMapping[value.key] as? [String:Any] {
                    if let toolMapping = mapping[tool] as? [String:Any] {
                        args.append(contentsOf: mappedSettings(for: value.key, value: value.value, mapping: toolMapping))
                    }
                }
            }
        }
        
        return args
    }
    
    static func mergedLists(_ l1 : SettingList?, _ l2 : SettingList?) -> SettingList {
        if l1 == nil {
            if l2 == nil {
                return []
            } else {
                return l2!
            }
        } else {
            if l2 == nil {
                return l1!
            } else {
                return l1! + l2!
            }
        }
    }
    
    static func mergedDictionaries(_ l1 : SettingsDictionary?, _ l2 : SettingsDictionary?) -> SettingsDictionary {
        if l1 == nil {
            if l2 == nil {
                return [:]
            } else {
                return l2!
            }
        } else {
            if l2 == nil {
                return l1!
            } else {
                return l1!.merging(l2!, uniquingKeysWith: { (l,r) in return l })
            }
        }
    }
    
    static func mergedSettings(_ s1 : Settings, _ s2 : Settings) -> Settings {
        return Settings(
            values: mergedDictionaries(s1.values, s2.values),
            inherits: nil)
    }
}
