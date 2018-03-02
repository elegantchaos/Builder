// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 02/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Data structure returned by the Configuration target.
 
 This structure describes the products to build, the
 settings to apply to them, and a list of executables
 to build and run before and after the build.
 
 The executables should themselves be specified as dependencies
 of the Configuration target, and will be built as part of building
 the configuration.
 
 In this way the entire toolchain is bootstrappable.
 */

struct Configuration : Decodable {
    let settings : [String:String]
    let products : [String]
    let prebuild : [String]
    let postbuild : [String]
    
    func compilerSettings() -> [String] {
        var args : [String] = []
        settings.forEach({ (key, value) in
            args.append(contentsOf: ["-Xswiftc", "-\(key)", "-Xswiftc", "\(value)"])
        })
        return args
    }
    
}

