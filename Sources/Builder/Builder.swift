// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 02/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

/**
 Builder.

 The basic algorithm is:

 - build and run the "Configuration" dependency, capturing the output
 - parse this output from JSON into a configuration structure
 - iterate through the targets in configuration.prebuild, building and executing each one
 - iterate through the products in configuration.products
 - iterate through the targets in configuration.postbuild, building and executing each one

 Building is done with `swift build`, and running with `swift run`.

 */

public class Builder {
    let command : String
    let configuration : String
    let output : Logger
    let verbose : Logger
    var environment : [String:String] = ProcessInfo.processInfo.environment

    lazy var swiftPath = findSwift()

    public init(command : String = "build", configuration : String = "debug", output: Logger, verbose: Logger) {
        self.command = command
        self.configuration = configuration
        self.output = output
        self.verbose = verbose

        // TODO: flesh the environment out with more useful stuff
        self.environment["BUILDER_COMMAND"] = command
        self.environment["BUILDER_CONFIGURATION"] = configuration
    }

    /**
     Return the path to the swift binary.
     */

    func findSwift() -> String {
        let path : String
        do {
            path = try run("/usr/bin/which", arguments:["swift"]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } catch {
            path = "/usr/bin/swift"
        }

        return path
    }


    /**
     Invoke a command and some optional arguments.
     Control is transferred to the launched process, and this function doesn't return.
     */

    func exec(_ command : String, arguments: [String] = []) {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        process.environment = self.environment
        process.launch()
        process.waitUntilExit()
        exit(process.terminationStatus)
    }


    /**
     Invoke a command and some optional arguments.
     On success, returns the captured output from stdout.
     On failure, throws an error.
     */

    func run(_ command : String, arguments: [String] = []) throws -> String {
        let pipe = Pipe()
        let handle = pipe.fileHandleForReading
        let errPipe = Pipe()
        let errHandle = errPipe.fileHandleForReading

        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = errPipe
        process.environment = self.environment
        process.launch()
        let data = handle.readDataToEndOfFile()
        let errData = errHandle.readDataToEndOfFile()

        process.waitUntilExit()
        let capturedOutput = String(data:data, encoding:String.Encoding.utf8)
        let status = process.terminationStatus
        if status != 0 {
            verbose.log("\(command) failed \(status)")
            let errorOutput = String(data:errData, encoding:String.Encoding.utf8)
            throw Failure.failed(output: capturedOutput, error: errorOutput)
        }

        if capturedOutput != nil {
            verbose.log("\(command) \(arguments)> \(capturedOutput!)")
        }

        return capturedOutput ?? ""
    }

    /**
     Invoke `swift` with a command and some optional arguments.
     On success, returns the captured output from stdout.
     On failure, throws an error.
     */

    func swift(_ command : String, arguments: [String] = []) throws -> String {
        verbose.log("running swift \(command)")
        return try run(swiftPath, arguments: [command] + arguments)
    }

    /**
     Parse some json into a Configuration structure.
     */

    func parse(configuration json : String) throws -> Configuration {
        guard let data = json.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Configuration.self, from: data)

        return decoded
    }

    /**
     Announce the build stage.
    */
    internal func setStage(_ stage : String, announce : Bool = true) {
        if announce {
            output.log("\n\(stage):")
        }
        environment["BUILDER_STAGE"] = stage.lowercased()
    }

    /**
     Execute the phases associated with a given scheme.
     */

    func execute(scheme name: String, configuration : Configuration, settings : [String]) throws {
        guard let scheme = configuration.schemes[name] else {
            throw Failure.missingScheme(name: name)
        }

        output.log("\nScheme:\n- \(name).")

        for phase in scheme {
            setStage(phase.name)
            let tool = phase.tool
            switch (tool) {
            case "test":
                let product = phase.arguments[0]
                let toolOutput = try swift("test", arguments: ["--configuration", self.configuration] + settings)
                output.log("- tested \(product).\n\n\(toolOutput)")
            case "run":
                let product = phase.arguments[0]
                let toolOutput = try swift("run", arguments: [product, "--configuration", self.configuration] + settings)
                output.log("- ran \(product).\n\n\(toolOutput)")
            case "build":
                let product = phase.arguments[0]
                let _ = try swift("build", arguments: ["--product", product, "--configuration", self.configuration] + settings)
                output.log("- built \(product).")
            case "scheme":
                let scheme = phase.arguments[0]
                try execute(scheme: scheme, configuration: configuration, settings: settings)
            default:
                let toolOutput = try swift("run", arguments: [tool] + phase.arguments)
                output.log("- ran \(tool): \(toolOutput)")
            }
        }
    }

    /**
     Perform the build.
     */

    public func execute(configurationTarget : String) throws {
        // try to build the Configure target
        setStage("Configuring", announce: false)
        do {
            let _ = try swift("build", arguments: ["--product", configurationTarget])
        } catch Failure.failed(let stdout, let stderr) {
            if stderr == "error: no product named \'\(configurationTarget)\'\n" {
                exec(swiftPath, arguments: Array(CommandLine.arguments[1...]))
            } else {
                throw Failure.failed(output: stdout, error: stderr)
            }
        }

        // if we built it, run it, and parse its output as a JSON configuration
        // (we don't use `swift run` here as we don't want to capture any of its output)
        setStage("Configuring")
        let binPath = try swift("build", arguments: ["--product", configurationTarget, "--show-bin-path"])
        output.log("- running config")
        let configurePath = URL(fileURLWithPath:binPath.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).appendingPathComponent(configurationTarget).path
        let json = try run(configurePath)
        output.log("- parsing output")
        let configuration = try parse(configuration: json)

        let settings = configuration.compilerSettings()
        environment["BUILDER_SETTINGS"] = settings.joined(separator: ",")

        // execute the scheme associated with the primary command we were passed (run/build/test/etc)
        try execute(scheme: command, configuration: configuration, settings: settings)

        output.log("\nDone.\n\n")
    }

}
