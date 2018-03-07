// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let doc = """
Build, test, and run SwiftPM packages.

Usage:
    builder [<command>] [--configuration <config>]
    builder (-h | --help)

Arguments:
    <command>                       The command to execute [default: build].


Options:
    -h, --help                      Show this text.
    -c, --configuration <config>    The configuration to build [default: debug].
    -logs <logs>                    Specify all log channels to enable.
    -logs+ <logs>                   Specify additional log channels to enable.
    -logs- <logs>                   Specify log channels to disable.

Examples:
    builder build --configuration release
    builder test



"""

let output = Logger.stdout
let verbose = Logger("com.elegantchaos.builder.verbose", handlers:[PrintHandler()])

var args = Arguments(documentation: doc)
let command = args.argument("command", default: "build")

do {
    let configuration = try args.option("configuration")
    let builder = Builder(command: command, configuration: configuration)
    try builder.execute(configurationTarget: "Configure")

} catch Failure.decodingFailed {
    output.log("Couldn't decode JSON")

} catch Failure.failed(let stdout, let stderr) {
    output.log(stdout ?? "Failure:")
    output.log(stderr ?? "")

} catch Failure.missingScheme(let name) {
    output.log("Couldn't find scheme: \(name)")

} catch Failure.unknownOption(let name) {
    output.log("Tried to read unknown option: \(name)")

} catch {
    output.log("Failed: \(error)")
}


