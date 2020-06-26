// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RunAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        var (product, args) = try super.arguments(for: phase, configuration: configuration, settings: settings)
        args.append("--show-bin-path")
        let path = try engine.swift("build", arguments: args).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let url = URL(fileURLWithPath: path).appendingPathComponent(product)
        var combinedArguments = engine.arguments
        combinedArguments += Array(phase.arguments.dropFirst())
        let toolOutput = try engine.run(url.path, arguments: combinedArguments)
        engine.output.log("\(engine.indent)Ran \(product).\n\n\(toolOutput)")
    }
}

