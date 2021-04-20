// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


class SettingsMapper {
    typealias Item = [String:Any]
    typealias Items = [String:Item]

    let tool : String
    var items : Items

    init(tool: String, items: Items = [:]) {
        self.tool = tool
        self.items = items
    }

}

class SettingsManager {
    var mappings: [String:SettingsMapper.Items] = [:]
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
