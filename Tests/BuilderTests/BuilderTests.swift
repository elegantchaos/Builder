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
        let s1 = Settings(values: ["key1" : "value1", "key2" : "value2"], inherits: nil)
        let s2 = Settings(values: ["key1" : "value1/2", "key3" : "value3"], inherits: nil)

        let s1s1 = Settings.mergedSettings(s1, s1).values!
        XCTAssertEqual(s1s1["key1"]!, "value1")
        XCTAssertEqual(s1s1["key2"]!, "value2")
        XCTAssertNil(s1s1["key3"])

        let s1s2 = Settings.mergedSettings(s1, s2).values!
        XCTAssertEqual(s1s2["key1"]!, "value1")
        XCTAssertEqual(s1s2["key2"]!, "value2")
        XCTAssertEqual(s1s2["key3"]!, "value3")

        let s2s1 = Settings.mergedSettings(s2, s1).values!
        XCTAssertEqual(s2s1["key1"]!, "value1/2")
        XCTAssertEqual(s1s2["key2"]!, "value2")
        XCTAssertEqual(s1s2["key3"]!, "value3")

        let s2s2 = Settings.mergedSettings(s2, s2).values!
        XCTAssertEqual(s2s2["key1"]!, "value1/2")
        XCTAssertNil(s2s2["key2"])
        XCTAssertEqual(s2s2["key3"]!, "value3")
    }

    func testSwiftSettingsMapping() throws {
        let settingsJSON = """
            {
              "values" : {
                "optimisation" : "none",
                "minimum-target" : "macosx10.12",
                "definition" : "example"
                },
            }
            """

        guard let data = settingsJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let settings = try decoder.decode(Settings.self, from: data)

        let mapped = settings.mappedSettings(for: "swift")
        XCTAssertEqual(mapped, ["-Xswiftc", "-Dexample", "-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12", "-Xswiftc", "-Onone"])
    }

    func testXCConfigSettingsMapping() throws {
        let settingsJSON = """
            {
              "values" : {
                "optimisation" : "none",
                "minimum-target" : "macosx10.12",
                "definition" : "example"
                },
            }
            """

        guard let data = settingsJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }

        let decoder = JSONDecoder()
        let settings = try decoder.decode(Settings.self, from: data)

        let mapped = settings.mappedSettings(for: "xcconfig")
        XCTAssertEqual(mapped, ["MACOSX_DEPLOYMENT_TARGET = ", "10.12", "SWIFT_OPTIMIZATION_LEVEL = ", "-Onone"])
    }

    func testPlatformOverrides() throws {
        let platformOverrideJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "extraMacSettings", "filter" : ["macOS"] }],
                          "values" : {
                            "optimisation" : "none",
                            },
                    },
                    "extraMacSettings" : {
                      "values" : {
                        "minimum-target" : "macosx10.12"
                        },
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

        // when we say the platform is macOS, we should get the extra settings mixed in from "extraMacSettigns"
        let macSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(macSettings.mappedSettings(for: "swift"), ["-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12", "-Xswiftc", "-Onone"])

        // when we say the platform is linux, we should just get the base settings
        let linuxSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"linux")
        XCTAssertEqual(linuxSettings.mappedSettings(for: "swift"), ["-Xswiftc", "-Onone"])

    }

    func testInheritanceChain() throws {
        let chainJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "inherited1"}],
                          "values" : {
                            "optimisation" : "none",
                            },
                    },
                    "inherited1" : {
                        "inherits" : [{ "name" : "inherited2"}],
                      "values" : {
                        "minimum-target" : "macosx10.12"
                        },
                    },
                    "inherited2" : {
                      "values" : {
                        "definition" : ["example", "example2"]
                        },
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

        // we should get all the inherited settings
        let settings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(settings.mappedSettings(for: "swift"), ["-Xswiftc", "-Dexample", "-Xswiftc", "-Dexample2", "-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12", "-Xswiftc", "-Onone"])
    }

    func testConfigurationOverrides() throws {
        let configurationOverrideJSON = """
            {
                "settings" : {
                    "«base»" : {
                        "inherits" : [{ "name" : "extraReleaseSettings", "filter" : ["release"] }],
                          "values" : {
                            "minimum-target" : "macosx10.12"
                            },
                    },
                    "extraReleaseSettings" : {
                        "values" : {
                            "optimisation" : "speed",
                        }
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

        // when we say the config is debug, we should just get the base settings
        let debugSettings = try configuration.resolve(for: "action1", configuration: "debug", platform:"macOS")
        XCTAssertEqual(debugSettings.mappedSettings(for: "swift"), ["-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12"])

        // when we say the config is release, we should get the extra optimisation setting
        let releaseSettings = try configuration.resolve(for: "action1", configuration: "release", platform:"macOS")
        XCTAssertEqual(releaseSettings.mappedSettings(for: "swift"), ["-Xswiftc", "-target", "-Xswiftc", "x86_64-apple-macosx10.12", "-Xswiftc", "-O"])
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
        ("testSwiftSettingsMapping", testSwiftSettingsMapping),
        ("testXCConfigSettingsMapping", testXCConfigSettingsMapping),
        ("testPlatformOverrides", testPlatformOverrides),
        ("testConfigurationOverrides", testConfigurationOverrides),
        ("testInheritanceChain", testInheritanceChain),
        ("testSchemes", testSchemes),
    ]
}
