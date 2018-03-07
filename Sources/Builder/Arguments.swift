// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


struct Arguments {
  struct Option {
    let name : String
    let consume : Bool
    let hasValue : Bool

    init(_ name : String, consume : Bool = false, hasValue : Bool = false) {
      self.name = name
      self.consume = consume
      self.hasValue = hasValue
    }
  }

  let application : String
  let options : [String:String]
  var unused : [String] = []
  init(options recognisedOptions : [Option]) {

    var options : [String:String] = [:]
    var valueOwner : Option?
    for argument in CommandLine.arguments {
      if let option = valueOwner {
        options[option.name] = argument
        if !option.consume {
          unused.append(argument)
        }
      } else if argument.starts(with:"-") {
        for option in recognisedOptions {
          if argument == option.name {
            if option.hasValue {
              valueOwner = option
            } else {
              options[argument] = "true"
            }
            if !option.consume {
              unused.append(argument)
            }
          }
        }
      } else if argument != "" {
        unused.append(argument)
      }
    }

    self.options = options
    self.application = unused[0]
    unused.removeFirst()
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
