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
