import Foundation
import Logger

let logger = Logger("com.elegantchaos.builder.main")

func swift(_ command : String, arguments: [String] = []) {
    let pipe = Pipe()
    let handle = pipe.fileHandleForReading
    let process = Process()
    process.launchPath = "/usr/bin/swift"
    process.arguments = [command] + arguments
    process.standardOutput = pipe
    process.launch()
    let data = handle.readDataToEndOfFile()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        logger.log("\(arguments[0]) failed")
    }
    if let output = String(data:data, encoding:String.Encoding.utf8) {
        print("\(command)> \(output)")
    }
}

func build() {
    swift("build")
    swift("run")
//    let process = Process()
//    process.launchPath = "/usr/bin/swift"
//    process.arguments = ["build"]
//    process.launch()
//    process.waitUntilExit()
//    if process.terminationStatus != 0 {
//        logger.log("build failed")
//    }
}

build()
