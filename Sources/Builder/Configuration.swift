// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 02/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

typealias SettingList = [String]
typealias SettingsDictionary = [String:String]

// TODO: this should really be read from a json file or series of json files (one per tool/platform?)
// TODO: it would also make sense to allow users to add/contribute to it somehow
let settingsMapping : [String:Any] = [
    "minimum-target": [
        "swift" : [
            "prefix": ["-Xswiftc", "-target", "-Xswiftc"],
            "values": [
                "macosx10.12" : "x86_64-apple-macosx10.12"
            ]
        ],
        "xcconfig": [
            "prefix": ["\nMACOSX_DEPLOYMENT_TARGET = "],
            "values" : [
                "macosx10.12": "10.12"
            ]
        ]
    ],
    "optimisation": [
        "swift" : [
            "prefix": ["-Xswiftc"],
            "values": [
                "none": "-Onone"
            ]
        ]
    ],
    
    "definition": [
    ]
]


struct Inheritance : Decodable {
    let name : String
    let filter : [String]?
}

struct Settings : Decodable {
    let common : SettingList?
    let c : SettingList?
    let cpp : SettingList?
    let swift : SettingList?
    let linker : SettingList?
    let values : SettingsDictionary?
    let inherits : [Inheritance]?
    
    func mappedSettings(for name: String, value: String, mapping: [String:Any]) -> [String] {
        var result: [String] = []
        if let prefix = mapping["prefix"] as? [String] {
            result.append(contentsOf: prefix)
        }
        
        if let valueMappings = mapping["values"] as? [String:Any] {
            if let value = valueMappings[value] as? String {
                result.append(value)
            } else if let values = valueMappings[value] as? [String] {
                result.append(contentsOf: values)
            }
        }

        return result
    }
    
    func compilerSettings(for tool: String) -> [String] {
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
//        swift?.forEach({ args.append(contentsOf: ["-Xswiftc", "-\($0)"])})
//        c?.forEach({ args.append(contentsOf: ["-Xc", "-\($0)"])})
//        cpp?.forEach({ args.append(contentsOf: ["-Xcpp", "-\($0)"])})
//        linker?.forEach({ args.append(contentsOf: ["-Xlinker", "-\($0)"])})

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
            common: mergedLists(s1.common, s2.common),
            c: mergedLists(s1.c, s2.c),
            cpp: mergedLists(s1.cpp, s2.cpp),
            swift: mergedLists(s1.swift, s2.swift),
            linker: mergedLists(s1.linker, s2.linker),
            values: mergedDictionaries(s1.values, s2.values),
            inherits: nil)
    }
}

/**
 Data structure representing a phase of the build process.
 
 The name is optional, and for information purposes only.
 The tool is either a special built-in command, or the
 name of a tool dependendency to build and run.
 The arguments are passed to the tool or built-in.
 */

struct Phase : Decodable {
    let name : String
    let command : String
    let arguments : [String]
}

/**
 Data structure returned by the Configuration target.
 
 This structure describes the products to build, the
 settings to apply to them, and a list of executables
 to build and run before and after the build.
 
 The executables should themselves be specified as dependencies
 of the Configuration target, and will be built as part of building
 the configuration.
 
 In this way the entire toolchain is bootstrappable.
 */

struct Configuration : Decodable {
    let settings : [String:Settings]
    let actions : [String:[Phase]]
    
    func applyInheritance(to settings : Settings, filter : [String]) throws -> Settings {
        guard let inherited = settings.inherits else {
            return settings
        }
        
        var merged = settings
        for sub in inherited {
            var match = sub.filter == nil || sub.filter!.count == 0
            if !match {
                for item in sub.filter! {
                    if filter.contains(item) {
                        match = true
                        break
                    }
                }
            }
            
            if match {
                guard let subSettings = self.settings[sub.name] else {
                    throw Failure.unknownOption(name: sub.name)
                }
                let subWithInheritance = try applyInheritance(to: subSettings, filter: filter)
                merged = Settings.mergedSettings(merged, subWithInheritance)
            }
        }
        
        return merged
    }
    
    public func resolve(for scheme : String, configuration : String, platform : String) throws -> Settings {
        var base = self.settings[scheme]
        if base == nil {
            base = self.settings["«base»"]
        }
        guard let settings = base else {
            throw Failure.unknownOption(name: scheme)
            
        }
        
        return try applyInheritance(to: settings, filter: [configuration, platform])
    }
}
