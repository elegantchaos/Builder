// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/06/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


/**
    Settings mapper for the Swift compiler.

    TODO: should probably be read from a configuration file
*/

class SwiftSettingsMapper: SettingsMapper {
    init() {
        super.init(tool: "swift", items: [
            "minimum-target": [
                "prefix": ["-Xswiftc", "-target", "-Xswiftc"],
                "values": [
                    "macosx10.11" : "x86_64-apple-macosx10.11",
                    "macosx10.12" : "x86_64-apple-macosx10.12",
                    "macosx10.13" : "x86_64-apple-macosx10.13",
                    "macosx10.14" : "x86_64-apple-macosx10.14"
                ]
            ],
            "optimisation": [
                "prefix": ["-Xswiftc"],
                "values": [
                    "none": "-Onone",
                    "size": "-Osize",
                    "speed": "-O"
                ]
            ],
            "definition": [
                "rawValues" : ["-Xswiftc", "-D"]
            ]
        ])
    }
}
