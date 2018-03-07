// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let output = Logger.stdout
let verbose = Logger("com.elegantchaos.builder.verbose", handlers:[PrintHandler()])

let options =     [
    Arguments.ValueOption("-logs"),
    Arguments.ValueOption("--configuration", default: "debug"),
    Arguments.BoolOption("--testBool")
]

var args = Arguments(options: options)
let command = args.pop(default: "build")

 do {
    let builder = Builder(command: command, configuration: args.option("--configuration"))
     try builder.build(configurationTarget: "Configure")
 } catch Failure.decodingFailed {
     output.log("Couldn't decode JSON")
 } catch Failure.failed(let stdout, let stderr) {
     output.log(stdout ?? "Failure:")
     output.log(stderr ?? "")
 } catch Failure.missingScheme(let scheme) {
     output.log("Couldn't find scheme: \(scheme)")
 } catch {
     output.log("Failed: \(error)")
 }

