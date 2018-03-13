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
    func testExample() throws {
        guard let data = json.data(using: String.Encoding.utf8) else {
            throw Failure.decodingFailed
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Configuration.self, from: data)

      print("test goes here")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
