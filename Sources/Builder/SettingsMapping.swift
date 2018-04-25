// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

// TODO: this should really be read from a json file or series of json files (one per tool/platform?)
// TODO: it would also make sense to allow users to add/contribute to it somehow
let settingsMapping : [String:Any] = [
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

