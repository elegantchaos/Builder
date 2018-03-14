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

let configuration = Configuration(
    settings: settings,
    schemes: [
        .scheme(name:"build", phases:[
            .phase(name:"Preparing", tool: "BuilderToolExample", arguments:[]),
            .phase(name:"Building", tool: "build", arguments:["Example"]),
            .phase(name:"Packaging", tool: "BuilderToolExample", arguments:["blah", "waffle"]),
            ]),
        .scheme(name:"test", phases:[
            .phase(name:"Testing", tool: "test", arguments:["Example"]),
            ]),
        .scheme(name:"run", phases:[
            .phase(name:"Building", tool: "scheme", arguments:["build"]),
            .phase(name:"Running", tool: "run", arguments:["Example"]),
            ]),
    ]
)

configuration.outputToBuilder()
