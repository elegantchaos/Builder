// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 13/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Builder


class BuilderTests: XCTestCase {
    func testMergingSettingLists() {
        XCTAssertEqual(Settings.mergedLists(nil, nil), [])
        XCTAssertEqual(Settings.mergedLists(["blah"], nil), ["blah"])
        XCTAssertEqual(Settings.mergedLists(nil, ["waffle"]), ["waffle"])
        XCTAssertEqual(Settings.mergedLists(["blah"], ["waffle"]), ["blah", "waffle"])
    }

    func testMergingSettings() {
        let s1 = Settings(common: nil, c: nil, cpp: nil, swift: nil, linker: nil, inherits: nil)
        let s2 = Settings(common: ["test"], c: nil, cpp: nil, swift: nil, linker: nil, inherits: nil)

        XCTAssertEqual(Settings.mergedSettings(s1, s1).common!, [])
        XCTAssertEqual(Settings.mergedSettings(s1, s2).common!, ["test"])
        XCTAssertEqual(Settings.mergedSettings(s2, s1).common!, ["test"])
        XCTAssertEqual(Settings.mergedSettings(s2, s2).common!, ["test", "test"])
    }

    func testCompilerSetting() throws {
        let compilerSettingsJSON = """
            {
              "cpp" : ["testCpp"],
              "swift" : ["testSwift"],
              "common" : ["testCommon"],
              "c" : ["testC"],
              "linker" : ["testLinker"]
            }
            """

        guard let data = compilerSettingsJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let settings = try decoder.decode(Settings.self, from: data)

        let compiler = settings.compilerSettings()
        XCTAssertEqual(compiler, ["-Xswiftc", "-testSwift", "-Xc", "-testC", "-Xcpp", "-testCpp", "-Xlinker", "-testLinker"])
    }

    func testPlatformOverrides() throws {
        let platformOverrideJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "extraMacSettings", "filter" : ["macOS"] }],
                        "swift" : ["testSwift"],
                    },
                    "extraMacSettings" : {
                      "swift" : ["extraMacOnly"],
                    }
                },
                "actions" : {
                    "action1" : [ {"command" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]} ],
                }
            }
            """

        guard let data = platformOverrideJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let configuration = try decoder.decode(Configuration.self, from: data)

        let macSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(macSettings.compilerSettings(), ["-Xswiftc", "-testSwift", "-Xswiftc", "-extraMacOnly"])

        let linuxSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"linux")
        XCTAssertEqual(linuxSettings.compilerSettings(), ["-Xswiftc", "-testSwift"])

    }

    func testInheritanceChain() throws {
        let chainJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "inherited1"}],
                        "swift" : ["testSwift"],
                    },
                    "inherited1" : {
                        "inherits" : [{ "name" : "inherited2"}],
                      "swift" : ["extraInherited1"]
                    },
                    "inherited2" : {
                      "swift" : ["extraInherited2"],
                    }
                },
                "actions" : {
                    "action1" : [ {"command" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]} ],
                }
            }
            """

        guard let data = chainJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let configuration = try decoder.decode(Configuration.self, from: data)

        let settings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(settings.compilerSettings(), ["-Xswiftc", "-testSwift", "-Xswiftc", "-extraInherited1", "-Xswiftc", "-extraInherited2"])
    }

    func testConfigurationOverrides() throws {
        let configurationOverrideJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "extraReleaseSettings", "filter" : ["release"] }],
                        "swift" : ["testSwift"],
                    },
                    "extraReleaseSettings" : {
                      "swift" : ["extraReleaseOnly"],
                    }
                },
                "actions" : {
                    "action1" : [ {"command" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]} ],
                }
            }
            """

        guard let data = configurationOverrideJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let configuration = try decoder.decode(Configuration.self, from: data)

        let debugSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(debugSettings.compilerSettings(), ["-Xswiftc", "-testSwift"])

        let releaseSettings = try configuration.resolve(for: "action1", configuration: "release", platform:"macOS")
        XCTAssertEqual(releaseSettings.compilerSettings(), ["-Xswiftc", "-testSwift", "-Xswiftc", "-extraReleaseOnly"])
    }

    func testSchemes() throws {
        let simpleSchemesJSON = """
            {
                "settings" : { "common" : { } },
                "actions" : {
                    "action1" : [
                        {"command" : "tool1", "name" : "test1", "arguments" : ["arg1"]},
                        {"command" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]}
                    ],
                    "action2" : [
                        {"command" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]}
                    ]
                }
            }
            """

        guard let data = simpleSchemesJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let configuration = try decoder.decode(Configuration.self, from: data)
        XCTAssertEqual(configuration.actions.count, 2)
        guard let action1 = configuration.actions["action1"] else { XCTFail("missing scheme"); return }
        XCTAssertEqual(action1.count, 2)
        guard let action2 = configuration.actions["action2"] else { XCTFail("missing scheme"); return }
        XCTAssertEqual(action2.count, 1)
    }

    static var allTests = [
        ("testMergingSettingLists", testMergingSettingLists),
        ("testMergingSettings", testMergingSettings),
        ("testCompilerSetting", testCompilerSetting),
        ("testPlatformOverrides", testPlatformOverrides),
        ("testConfigurationOverrides", testConfigurationOverrides),
        ("testInheritanceChain", testInheritanceChain),
        ("testSchemes", testSchemes),
    ]
}
