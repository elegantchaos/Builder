// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 07/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Rudimentary argument parsing.

 For a real implementation we'd be better off with something like docopt here.
 */

import Docopt

struct Arguments {
    let program : String
    let parsed : [String:Any]
    
    /**
     Parse the command line arguments.

     Any recognised options are pulled out into the options dictionary.
     Other arguments end up in the unused array (so that they can be passed on to a sub-process, for example).
     */

    init(documentation : String) {
        var args : [String] = []
        var dropNext = false
        for argument in CommandLine.arguments {
            if (argument == "-logs") || (argument == "-logs+" || argument == "-logs-") {
                dropNext = true
            } else if dropNext {
                dropNext = false
            } else {
                args.append(argument)
            }
        }

        self.program = args[0]
        args.removeFirst()
        self.parsed = Docopt.parse(doc, argv: args, help: true, version: "1.0")
    }
    
    /**
     Return an option.
     It's an error to try to read an option that wasn't passed in when
     we were set up.
     */
    
    func option(_ name : String) throws -> String  {
        if let value = parsed["--\(name)"] as? String {
            return value
        }
        
        throw Failure.unknownOption(name: name)
    }

    /**
     Return an argument, or a default value if it's missing.
     */
    
    func argument(_ name : String, `default` : String) -> String  {
        if let value = parsed["<\(name)>"] as? String {
            return value
        }
        return `default`
    }

}
