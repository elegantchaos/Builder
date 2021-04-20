// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class MetadataAction: BuilderAction {
    override func run(phase: Phase, configuration : Configuration, settings: [String]) throws {
        let product = phase.arguments[0]
        let plist = phase.arguments.count > 1 ? phase.arguments[1] : "Sources/\(product)/Info.plist"
        writeMetadata(product: product, plistPath: plist)
    }

    func writeMetadata(product: String, plistPath: String) {
        let environment = engine.environment
        var info: [String:Any] = [:]

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        if let data = try? Data(contentsOf: cwd.appendingPathComponent(plistPath)) {
            if let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) {
                if let existing = plist as? [String:Any] {
                    info.merge(existing, uniquingKeysWith: { (key1, key2) in return key1 })
                }
            }
        }

        info["CFBundleVersion"] = environment["BUILDER_BUILD"]
        info["CFBundleShortVersionString"] = environment["BUILDER_VERSION"]
        info["GitCommit"] = environment["BUILDER_GIT_COMMIT"]
        info["GitTags"] = environment["BUILDER_GIT_TAGS"]

        let path = engine.linkablePlistPath(for: product)
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            print(error)
        }
    }
}
