// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 13/07/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class BuilderAction {
    let engine: Builder

    init(engine: Builder) {
        self.engine = engine
    }

    func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
    }

    func arguments(for phase: Phase, configuration : Configuration, settings: [String]) throws -> (String, [String]) {
        var args: [String] = []
        args.append(contentsOf: ["--configuration", engine.configuration])
        var product = "default product"
        if phase.arguments.count > 0 {
            product = phase.arguments[0]
            args.append("--product")
            args.append(product)
        }
        
        args.append(contentsOf: settings)
        return (product, args)
    }
}




class TestAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let product = phase.arguments[0]
        let toolOutput = try engine.swift("test", arguments: ["--configuration", engine.configuration] + settings)
        engine.output.log("\(engine.indent)- tested \(product).\n\n\(toolOutput)")
    }
}

class ActionAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let action = phase.arguments[0]
        try engine.execute(action: action, configuration: configuration, settings: settings)
    }
}

class DefaultAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let command = phase.command
        let toolOutput = try engine.swift("run", arguments: settings + [command] + phase.arguments)
        engine.verbose.log("\(engine.indent)- ran \(command): \(toolOutput)")
    }
}
