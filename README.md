# Builder

This is a very simple proof-of-concept implementation of a meta-build command for the Swift Package Manager, as described [in the Swift forums](https://forums.swift.org/t/spm-static-dependencies/10152/35?u=samdeane).

The executable tool built by this package is intended to be used _to build other Swift Package Manager packages_.

An example package is provided, which you can run the tool on.

To build & test the builder:

```
swift package update
swift package clean
swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
cd Example
../.build/debug/Builder
.build/debug/Example
```

What this does is to build the Builder tool itself, then run it to build the Example package.

When running over the example package, the tool:

- builds & runs the Configuration target from the package manifest
- uses the output of this to obtain the build configuration
- extracts build settings from this configuration
- builds & runs any pre-build tools listed in the configuration
- builds the products listed in the configuration, applying the settings it extracted previously
- builds & runs any post-build tools listed in the configuration

Finally, the script runs the built example product.

### Discussion

In this demo, the Configuration target from the example project actually embeds the configuration as a dictionary inside itself, and returns it as JSON when run.

This is the complete source for it:

```
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
```

This illustrates the fact that the configuration actually being generated dynamically and therefore could change based on the environment it's run in.

However, with a minor bit of tweaking of the design, it would also be possible for the Configuration target itself to be an external dependency.

This would effectively define a pre-defined strategy to find the configuration (the strategy being whatever the dependent tool does when it's run). For example, one strategy could just be to look for a file called `Configuration.json` in the working directory and return the contents of that.

In this way, it would be possible for this system to operate without any code needing to be written for simple cases - whilst still allowing infinite complexity when required.



### Caveats

I hacked this together as a demo, so it may not build on your system.

In theory it should work on Linux, but it currently has Foundation dependencies. These should be surmountable in a real implementation.

Things that have been glossed over:

- passing in useful environment to the helper executables (Configure and Tool)
- building/running the tool executables from sub-dependencies -- in principle this should be fine I think, I just wanted to keep the demo self-contained
- niceties such as error checking, help, etc, etc...

In theory it should be perfectly possible for the tool to also:
- generate an xcconfig file for the xcode project
- generate the xcode project
- generate proper dependencies and build phases to get xcode to run the tools just like the command line version does (hard, but by no means impossible)
