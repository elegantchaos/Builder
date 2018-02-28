import Foundation

let configuration : [String:Any] = [
    "settings" : [
      "target" : "x86_64-apple-macosx10.12"
    ],

    "prebuild" : ["Tool"],
    "postbuild" : ["Tool"],
    "products" : ["Example"]
]

let encoded = try JSONSerialization.data(withJSONObject: configuration, options: .prettyPrinted)
if let json = String(data: encoded, encoding: String.Encoding.utf8) {
    print(json)
}
