// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class MetafileAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let product = phase.arguments[0]
        writeMetafile(product: product)
    }

    func writeMetafile(product: String) {
        let path = "Sources/\(product)/meta.swift"
        let environment = engine.environment
        
        let source = """
            struct Metadata {
                let build = "\(environment["BUILDER_BUILD"]!)"
                let version = "\(environment["BUILDER_VERSION"]!)"
                let commit = "\(environment["BUILDER_GIT_COMMIT"]!)"
                let tags = "\(environment["BUILDER_GIT_TAGS"]!)"
        
                static var main = Metadata()
            }
        
        """

        do {
            if let data = source.data(using: .utf8) {
                try data.write(to: URL(fileURLWithPath: path))
            }
        } catch {
            print(error)
        }
    }
}
