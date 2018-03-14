// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import BuilderBasicConfigure

let settings = Settings(schemes: [
    .scheme(
        name: "common",
        swift: ["Dexample"],
        inherits: [
            .scheme(name: "mac", filter: ["macOS"]),
            .scheme(name: "debug", filter: ["debug"])
        ]
    ),
    .scheme(
        name: "mac",
        swift: ["target", "x86_64-apple-macosx10.12"]
    ),
    .scheme(
        name: "debug",
        swift: ["Onone"]
    )
    ]
)

let configuration : [String:Any] = [
    "settings" : settings.value,
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
