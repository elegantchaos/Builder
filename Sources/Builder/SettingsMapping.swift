// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SettingsMapper {

    let tool : String
    var items : [String:[String:Any]] = [:]

    init(tool: String) {
        self.tool = tool
    }

}

class SettingsManager {
    var mappings: [String:[String:[String:Any]]] = [
        "minimum-target": [
            "swift" : [
                "prefix": ["-Xswiftc", "-target", "-Xswiftc"],
                "values": [
                    "macosx10.12" : "x86_64-apple-macosx10.12",
                    "macosx10.13" : "x86_64-apple-macosx10.13"
                ]
            ],
            "xcconfig": [
                "prefix": ["MACOSX_DEPLOYMENT_TARGET = "],
                "values" : [
                    "macosx10.12": "10.12",
                    "macosx10.13": "10.13"
                ]
            ]
        ],
        "optimisation": [
            "swift" : [
                "prefix": ["-Xswiftc"],
                "values": [
                    "none": "-Onone",
                    "size": "-Osize",
                    "speed": "-O"
                ]
            ],
            "xcconfig" : [
                "prefix" : ["SWIFT_OPTIMIZATION_LEVEL = "],
                "values": [
                    "none": "-Onone",
                    "size": "-Osize",
                    "speed": "-O"
                ]
            ]
        ],

        "definition": [
            "swift" : [
                "rawValues" : ["-Xswiftc", "-D"]
            ],
        ]
    ]

    var mappers: [SettingsMapper] = []

    func addMapper(_ mapper: SettingsMapper) {
        self.mappers.append(mapper)

        let tool = mapper.tool
        for item in mapper.items {
            if var itemMappings = mappings[item.key] {
                itemMappings[tool] = item.value
            } else {
                mappings[item.key] = [tool: item.value]
            }
        }
    }


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

    func mappedSettings(tool: String, settings: Settings) -> [String] {
        var args : [String] = []

        if let values = settings.values {
            let sortedKeys = values.keys.sorted()
            for key in sortedKeys {
                let value = values[key]!
                if let mapping = mappings[key] {
                    if let toolMapping = mapping[tool] {
                        args.append(contentsOf: mappedSettings(for: key, value: value, mapping: toolMapping))
                    }
                }
            }
        }

        return args
    }
}
