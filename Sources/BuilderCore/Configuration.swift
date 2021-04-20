// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 02/03/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation





/**
 Data structure representing a phase of the build process.
 
 The name is optional, and for information purposes only.
 The tool is either a special built-in command, or the
 name of a tool dependendency to build and run.
 The arguments are passed to the tool or built-in.
 */

struct Phase : Decodable {
    let name : String
    let command : String
    let arguments : [String]
}

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
    let settings : [String:Settings]
    let actions : [String:[Phase]]
    
    func applyInheritance(to settings : Settings, filter : [String]) throws -> Settings {
        guard let inherited = settings.inherits else {
            return settings
        }
        
        var merged = settings
        for sub in inherited {
            var match = sub.filter == nil || sub.filter!.count == 0
            if !match {
                for item in sub.filter! {
                    if filter.contains(item) {
                        match = true
                        break
                    }
                }
            }
            
            if match {
                guard let subSettings = self.settings[sub.name] else {
                    throw Failure.unknownOption(name: sub.name)
                }
                let subWithInheritance = try applyInheritance(to: subSettings, filter: filter)
                merged = Settings.mergedSettings(merged, subWithInheritance)
            }
        }
        
        return merged
    }
    
    public func resolve(for scheme : String, configuration : String, platform : String) throws -> Settings {
        var base = self.settings[scheme]
        if base == nil {
            base = self.settings["«base»"]
        }
        guard let settings = base else {
            throw Failure.unknownOption(name: scheme)
            
        }
        
        return try applyInheritance(to: settings, filter: [configuration, platform])
    }
}
