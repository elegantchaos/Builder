// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Builder
import Foundation

let doc = """
Build, test, and run SwiftPM packages.

Usage:
    builder [<action>] [--configuration <config>] [--platform <platform>] [--] [<other>...]
    builder (-h | --help)

Arguments:
    <action>                       The action to perform [default: build].


Options:
    -h, --help                      Show this text.
    -c, --configuration <config>    The configuration to build [default: debug].
    -p, --platform <platform>       The platform to build. Defaults to the current platform you're building on.
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
let command = args.argument("action", default: "build")

do {
    let configuration = try args.option("configuration")
    let platform = args.option("platform", default:Platform.currentPlatform())
    let builder = Builder(command: command, configuration: configuration, platform: platform, output: output, verbose: verbose)
    try builder.execute(configurationTarget: "Configure")
} catch let error as Failure {
    error.logAndExit(output)
} catch let error as NSError {
    output.log("Failed: \(error)")
    exit(Int32(error.code))
} catch {
    output.log("Failed: \(error)")
    exit(-1)
}
