// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 28/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let output = Logger.stdout
let verbose = Logger("com.elegantchaos.builder.verbose", handlers:[PrintHandler()])

do {
    let builder = Builder()
    try builder.build(configurationTarget: "Configure")
} catch Failure.decodingFailed {
    output.log("Couldn't decode JSON")
} catch Failure.failed(let stdout, let stderr) {
    output.log(stdout ?? "Failure:")
    output.log(stderr ?? "")
} catch {
    output.log("Failed: \(error)")
}
