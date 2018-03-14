// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import BuilderConfiguration

let settings = Settings(schemes: [
    .baseScheme(
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
    actions: [
        .action(name:"build", phases:[
            .toolPhase(name:"Preparing", tool: "BuilderToolExample"),
            .buildPhase(name:"Building", target:"Example"),
            .toolPhase(name:"Packaging", tool: "BuilderToolExample", arguments:["blah", "waffle"]),
            ]),
        .action(name:"test", phases:[
            .testPhase(name:"Testing", target:"Example"),
            ]),
        .action(name:"run", phases:[
            .actionPhase(name:"Building", action: "build"),
            .toolPhase(name:"Running", tool: "run", arguments:["Example"]),
            ]),
    ]
)

configuration.outputToBuilder()
