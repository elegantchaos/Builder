// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 07/06/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


/**
    Settings mapper for generating XCConfig files.

    TODO: should probably be read from a configuration file
*/

class XCConfigSettingsMapper: SettingsMapper {
    init() {
        super.init(tool: "xcconfig", items: [
            "minimum-target": [
                "prefix": ["MACOSX_DEPLOYMENT_TARGET = "],
                "values" : [
                    "macosx10.12": "10.12",
                    "macosx10.13": "10.13"
                ]
            ],
            "optimisation": [
                "prefix" : ["SWIFT_OPTIMIZATION_LEVEL = "],
                "values": [
                    "none": "-Onone",
                    "size": "-Osize",
                    "speed": "-O"
                ]
            ]
        ])
    }
}
