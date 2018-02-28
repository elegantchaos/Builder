import Foundation

let output : [String:Any] = [
    "configuration" : [],
    "prebuild" : [],
    "postbuild" : []
]

let encoded = try JSONSerialization.data(withJSONObject: output, options: .prettyPrinted)
if let json = String(data: encoded, encoding: String.Encoding.utf8) {
    print("\(json)")
}
