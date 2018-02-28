import Foundation

let output : [String:Any] = [
    "configuration" : [
      "target" : "x86_64-apple-macosx10.12"

    ],

    "prebuild" : [

    ],

    "postbuild" : [

    ],

    "products" : [
      "Example"
    ]
]

let encoded = try JSONSerialization.data(withJSONObject: output, options: .prettyPrinted)
if let json = String(data: encoded, encoding: String.Encoding.utf8) {
    print("\(json)")
}
