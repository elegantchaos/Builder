import Foundation
import Logger

let logger = Logger("com.elegantchaos.builder.main")
let verbose = Logger("com.elegantchaos.builder.verbose")

enum Failure : Error {
    case failed(output : String?, error : String?)
    case encodingFailed
    case wrongType
}

func swift(_ command : String, arguments: [String] = []) throws -> String {
    logger.log("swift \(command)")
    let pipe = Pipe()
    let handle = pipe.fileHandleForReading
    let process = Process()
    process.launchPath = "/usr/bin/swift"           // should be discoverable
    process.arguments = [command] + arguments
    process.standardOutput = pipe
    process.launch()
    let data = handle.readDataToEndOfFile()
    process.waitUntilExit()
    let output = String(data:data, encoding:String.Encoding.utf8)
    let status = process.terminationStatus
    if status != 0 {
        logger.log("\(command) failed \(status)")
        throw Failure.failed(output: output, error: nil)
    }

    if output != nil {
        verbose.log("\(command)> \(output!)")
    }
    
    return output ?? ""
}

func parse(configuration json : String) throws -> [String:Any] {
    guard let data = json.data(using: String.Encoding.utf8) else {
        throw Failure.encodingFailed
    }
    
    guard let configuration = try JSONSerialization.jsonObject(with:data) as? [String:Any] else {
        throw Failure.wrongType
    }
    
    return configuration
}

func build() throws {
    // try to build the Configure target
    let _ = try swift("build", arguments: ["--target", "Configure"])
    
    // if we built it, run it, and parse its output as a JSON configuration
    let json = try swift("run", arguments: ["Configure"])
    let configuration = try parse(configuration: json)
    
    // process the configuration to do the actual build
    logger.log(configuration)
}

do {
    try build()
} catch {
    logger.log("Failed: \(error)")
}

