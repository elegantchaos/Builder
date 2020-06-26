// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import ArgumentParser
import Foundation

struct Command: ParsableCommand {
    static var configuration =
        CommandConfiguration(
            abstract: "Meta-builder tool for building swift products."
        )
    
    @Argument(help: "The action to perform.") var action: String?
    @Option(help: "The configuration to build.") var configuration = "debug"
    @Option(help: "The platform to build. Defaults to the current platform you're building on.") var platform: String?
    @Flag(help: "Show the version.") var version = false
    @Flag(help: "Show verbose logging.") var verbose = false
    @Argument(help: "") var rest: [String] = []
    
    func run() throws {
        if version {
            print("1.0")
        } else {
            let outputChannel = Logger.stdout
            let verboseChannel = Logger("com.elegantchaos.builder.verbose", handlers:[PrintHandler()])
            verboseChannel.enabled = verbose

            let command = action ?? "build"
            let builder = Builder(command: command, configuration: configuration, platform: platform ?? Platform.currentPlatform(), output: outputChannel, verbose: verboseChannel, arguments:rest)
            try builder.execute(configurationTarget: "Configure")
        }
    }
}

Command.main()

