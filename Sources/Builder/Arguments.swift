// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 07/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Rudimentary argument parsing.
 
 For a real implementation we'd be better off with something like docopt here.
 */

struct Arguments {
    
    internal class Option {
        let name : String
        let consume : Bool
        let hasValue : Bool
        let `default` : String?
        
        init(_ name : String, consume : Bool, hasValue : Bool, `default` : String?) {
            self.name = name
            self.consume = consume
            self.hasValue = hasValue
            self.default = `default`
        }
    }
    
    internal class BoolOption : Option {
        init(_ name : String, consume : Bool = true) {
            super.init(name, consume: consume, hasValue: false, default: "false")
        }
    }
    
    internal class ValueOption : Option {
        init(_ name : String, consume : Bool = true, `default` : String? = nil) {
            super.init(name, consume: consume, hasValue: true, default: `default`)
        }
    }
    
    private let options : [String:String]
    let application : String
    var unused : [String] = []
    
    /**
     Parse the command line arguments.
     
     Any recognised options are pulled out into the options dictionary.
     Other arguments end up in the unused array (so that they can be passed on to a sub-process, for example).
     */
    
    init(options recognisedOptions : [Option]) {
        
        var options : [String:String] = [:]
        for option in recognisedOptions {
            if option.default != nil {
                options[option.name] = option.default
            }
        }
        var valueOwner : Option?
        for argument in CommandLine.arguments {
            if let option = valueOwner {
                options[option.name] = argument
                if !option.consume {
                    unused.append(option.name)
                    unused.append(argument)
                }
                valueOwner = nil
            } else if argument.starts(with:"-") {
                var matched = false
                for option in recognisedOptions {
                    if argument == option.name {
                        matched = true
                        if option.hasValue {
                            valueOwner = option
                        } else {
                            options[argument] = "true"
                        }
                        break
                    }
                }
                if !matched {
                    unused.append(argument)
                }
            } else if argument != "" {
                unused.append(argument)
            }
        }
        
        self.options = options
        self.application = unused[0]
        self.unused.removeFirst()
    }
    
    /**
     Return an option, or a default value if it's missing.
     It's an error to try to read an option that wasn't passed in when
     we were set up.
     */
    
    func option(_ name : String) throws -> String  {
        guard let value = options[name] else {
            throw Failure.unknownOption(name: name)
        }
        
        return value
    }
    
    /**
     Shift a value off the front of the unused arguments, consuming it.
    */
    
    mutating func shift(`default`: String ) -> String {
        guard unused.count > 0 else {
            return `default`
        }
        
        let value = unused[0]
        unused.removeFirst()
        return value
    }
}
