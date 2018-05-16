// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 07/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Argument parsing.
 Uses Docopt for the heavy lifting, but performs a bit of preliminary
 cleanup first, and provides a simplified API to read options and arguments.
 */

import Docopt
import Logger

public struct Arguments {
    let program : String
    private let parsed : [String:Any]

    /**
     Parse the command line arguments.

     Any recognised options are pulled out into the options dictionary.
     Other arguments end up in the unused array (so that they can be passed on to a sub-process, for example).
     */

    public init(documentation : String) {
        let filteredArguments = Manager.removeLoggingOptions(from: CommandLine.arguments)
        self.program = filteredArguments[0]
        self.parsed = Docopt.parse(documentation, argv: Array(filteredArguments[1...]), help: true, version: "1.0")
    }

    /**
     Return an option.
     It's an error to try to read an option that wasn't passed in when
     we were set up.
     */

    public func option(_ name : String) throws -> String  {
        if let value = parsed["--\(name)"] as? String {
            return value
        }

        throw Failure.unknownOption(name: name)
    }

    /**
     Return an option, or a default value if it's missing.
     */

    public func option(_ name : String, `default`: String) -> String  {
        if let value = parsed["--\(name)"] as? String {
            return value
        }
        return `default`
    }

    /**
     Return an argument, or a default value if it's missing.
     */

    public func argument(_ name : String, `default` : String) -> String  {
        if let value = parsed["<\(name)>"] as? String {
            return value
        }
        return `default`
    }

}
