import Foundation

#if os(macOS)
let settings = ["target" : "x86_64-apple-macosx10.12"]
#else
let settings : [String:String] = [:]
#endif

let configuration : [String:Any] = [
    "settings" : settings,
    "prebuild" : ["Tool"],
    "postbuild" : ["Tool"],
    "products" : ["Example"]
]

let encoded = try JSONSerialization.data(withJSONObject: configuration, options: .prettyPrinted)
if let json = String(data: encoded, encoding: String.Encoding.utf8) {
    print(json)
}
