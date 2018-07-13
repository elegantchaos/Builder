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
}

class BuildAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let (product, args) = arguments(for: phase, configuration: configuration, settings: settings)
        let _ = try engine.swift("build", arguments: args)
        engine.output.log("\(engine.indent)Built \(product).")
    }

    func arguments(for phase: Phase, configuration : Configuration, settings: [String]) -> (String, [String]) {
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

class RunAction: BuildAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        var (product, args) = arguments(for: phase, configuration: configuration, settings: settings)
        args.append("--show-bin-path")
        let path = try engine.swift("build", arguments: args).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let url = URL(fileURLWithPath: path).appendingPathComponent(product)
        let toolOutput = try engine.run(url.path, arguments: Array(phase.arguments.dropFirst()))
        engine.output.log("\(engine.indent)Ran \(product).\n\n\(toolOutput)")
    }
}

class MetadataAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let product = phase.arguments[0]
        writeMetadata(product: product)
    }

    func writeMetadata(product: String) {
        let environment = engine.environment
        let build = environment["BUILDER_BUILD"] ?? "unknown"
        let commit = environment["BUILDER_GIT_COMMIT"] ?? "unknown"
        let tags = environment["BUILDER_GIT_TAGS"] ?? ""
        let version = environment["BUILDER_VERSION"] ?? "0.0.0"
        let metadata = """
        struct Metadata {
            let version: String
            let build: String
            let tags: String
            let commit: String
        }

        let \(product)Metadata = Metadata(version: "\(version)", build: "\(build)", tags: "\(tags)", commit: "\(commit)")
        """
        let metadataURL = URL(fileURLWithPath: "./Sources").appendingPathComponent(product).appendingPathComponent("Metadata.swift")
        do {
            try metadata.write(to: metadataURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(metadataURL)
            print(error)
        }
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
