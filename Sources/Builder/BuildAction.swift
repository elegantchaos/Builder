// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class BuildAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let (product, args) = try arguments(for: phase, configuration: configuration, settings: settings)
        let _ = try engine.swift("build", arguments: args)
        engine.output.log("\(engine.indent)Built \(product).")
    }

    override func arguments(for phase: Phase, configuration : Configuration, settings: [String]) throws -> (String, [String]) {
        var (product, args) = try super.arguments(for: phase, configuration: configuration, settings: settings)

        args.append("--show-bin-path")
        let path = try engine.swift("build", arguments: args).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        args.removeLast()

        // if something has placed an info plist file into the build products folder, link it in
        let infoPath = "\(path)/\(product)_info.plist"
        if FileManager.default.fileExists(atPath: infoPath) {
            args.append(contentsOf: ["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__Info_plist", "-Xlinker", infoPath])

            // remove executable to ensure it's re-linked
            let url = URL(fileURLWithPath: path).appendingPathComponent(product)
            try? FileManager.default.removeItem(at: url)
        }

        return (product, args)
    }
}
