// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 13/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Builder



let json = """

{
  "settings" : {
    "mac" : {
      "swift" : [
        "target",
        "x86_64-apple-macosx10.12"
      ]
    },
    "debug" : {
      "swift" : [
        "Onone"
      ]
    },
    "common" : {
      "inherits" : [
        {
          "name" : "macOS",
          "platform" : "macOS"
        },
        {
          "name" : "debug",
          "configuration" : "debug"
        }
      ],
      "cpp" : [

      ],
      "swift" : [

      ],
      "common" : [

      ],
      "c" : [

      ]
    }
  },
  "schemes" : {
    "test" : [
      {
        "tool" : "test",
        "name" : "Testing",
        "arguments" : [
          "Example"
        ]
      }
    ],
    "build" : [
      {
        "tool" : "BuilderToolExample",
        "name" : "Preparing",
        "arguments" : [
          ""
        ]
      },
      {
        "tool" : "build",
        "name" : "Building",
        "arguments" : [
          "Example"
        ]
      },
      {
        "tool" : "BuilderToolExample",
        "name" : "Packaging",
        "arguments" : [
          "blah",
          "blah"
        ]
      }
    ],
    "run" : [
      {
        "tool" : "scheme",
        "name" : "Building",
        "arguments" : [
          "build"
        ]
      },
      {
        "tool" : "run",
        "name" : "Running",
        "arguments" : [
          "Example"
        ]
      }
    ]
  }
}


"""

class BuilderTests: XCTestCase {
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
    
    func testSchemes() throws {
        let simpleSchemesJSON = """
            {
                "settings" : { "common" : { } },
                "schemes" : {
                    "scheme1" : [
                        {"tool" : "tool1", "name" : "test1", "arguments" : ["arg1"]},
                        {"tool" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]}
                    ],
                    "scheme2" : [
                        {"tool" : "tool2", "name" : "test2", "arguments" : ["arg2a", "arg2b"]}
                    ]
                }
            }
            """

        guard let data = simpleSchemesJSON.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }
        
        let decoder = JSONDecoder()
        let configuration = try decoder.decode(Configuration.self, from: data)
        XCTAssertEqual(configuration.schemes.count, 2)
        guard let scheme1 = configuration.schemes["scheme1"] else { XCTFail("missing scheme"); return }
        XCTAssertEqual(scheme1.count, 2)
        guard let scheme2 = configuration.schemes["scheme2"] else { XCTFail("missing scheme"); return }
        XCTAssertEqual(scheme2.count, 1)
    }

    static var allTests = [
        ("testCompilerSetting", testCompilerSetting),
        ("testSchemes", testSchemes),
    ]
}
