// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import BuilderBasicConfigure

let settings : [String:Any] = [
    "common" :    [
        "common" : [:],
        "c" : [:],
        "c++" : [:],
        "swift" : [:],
        "inherits" : [
            ["name": "macOS", "platform" : "macOS"],
            ["name": "debug", "configuration" : "debug"]
        ]
    ],
    "mac" :    [
        "swift" : [
            ["target", "x86_64-apple-macosx10.12"]
        ]
    ],
    "debug" : [
        "swift" : [
            "Onone"
        ]
    ]
]

let configuration : [String:Any] = [
    "settings" : settings,
    "schemes" : [
        "build" : [
            [
                "name" : "Preparing",
                "tool" : "BuilderToolExample",
                "arguments":[""]
            ],
            [
                "name" : "Building",
                "tool" : "build",
                "arguments":["Example"]
            ],
            [
                "name" : "Packaging",
                "tool":"BuilderToolExample",
                "arguments":["blah", "blah"]
            ]
        ],
        "test" : [
            [
                "name" : "Testing",
                "tool" : "test",
                "arguments":["Example"]
            ],
        ],
        "run" : [
            [
                "name" : "Building",
                "tool" : "scheme",
                "arguments":["build"]
            ],
            [
                "name" : "Running",
                "tool" : "run",
                "arguments":["Example"]
            ],
        ]
        
    ]
]

let configure = BasicConfigure(dictionary: configuration)
try configure.run()
