// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


struct Arguments {
    class Option {
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
    
    class BoolOption : Option {
        init(_ name : String, consume : Bool = true) {
            super.init(name, consume: consume, hasValue: false, default: "false")
        }
    }
    
    class ValueOption : Option {
        init(_ name : String, consume : Bool = true, `default` : String? = nil) {
            super.init(name, consume: consume, hasValue: true, default: `default`)
        }
    }
    
    let application : String
    let options : [String:String]
    var unused : [String] = []
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
    
    func option(_ name : String, `default` : String = "") -> String {
        guard let value = options[name] else {
            return `default`
        }
        
        return value
    }
    
    mutating func pop(`default`: String ) -> String {
        guard unused.count > 0 else {
            return `default`
        }
        
        let value = unused[0]
        unused.removeFirst()
        return value
    }
}
