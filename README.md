# Builder

This is a very simple proof-of-concept implementation of a meta-build command for the Swift Package Manager, as described [in the Swift forums](https://forums.swift.org/t/spm-static-dependencies/10152/35?u=samdeane).

The executable tool built by this package is intended to be used _to build other Swift Package Manager packages_.

An example package is provided, which you can run the tool on.

The prototype is a standalone tool but obviously a real implementation could be integrated into spm itself.


### Building

To build & test the builder:

```
swift package update
swift package clean
cd Example
swift run --package-path ../. --static-swift-stdlib -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
.build/debug/Example
```

What this does is to build and run the Builder tool itself, which then builds the Example package.

Finally, the script runs the built example product.

Please leave comments and suggestions on the Swift forums, or as issues in github.

## Discussion

The tool works by looking for a special "Configuration" target in the normal `Package.swift` file.

If it finds this target, it uses `swift build` and/or `swift run` to:

- build & run the Configuration target from the package manifest
- parse the output of this to obtain the build configuration to use
- build & run any pre-build tools listed in the configuration
- build the products listed in the configuration, applying any build settings from the configuration
- build & run any post-build tools listed in the configuration

The idea behind this approach is that:

- by moving the code for calculating the configuration into its own module, it should be possible to eliminate any non-deterministic swift from the manifest
- any modules required to determine the configuration can be listed in the manifest as dependencies of the Configuration target, in the normal way
- any tools required for custom build steps can also be listed in the manifest as dependencies

In this way, once you have spm on your platform (and assuming that this functionality was built into spm), you don't need to install anything else (with `brew`, `apt-get` etc).

The entire chain of build dependencies, including additional tools (such as `mogenerator`, `protobuf`, etc), can be fetched and built locally by spm itself.

This is intended to encourage, as much as possible, people to stay platform-neutral within the Swift ecosystem. It also makes it simple for people to share re-usable build tools, since they're just Swift packages - hopefully this would result in a range of tools to suit most needs, so the requirement to actually write bespoke code would be minimal.

Of course, if you *do* have special requirements, such as tools that need to be installed or run with another package manager, it's no problem. Since you can also build and run arbitrary modules as part of the build process, and since they are just normal swift code, you can do anything that you need to by just writing one or more Swift scripts.

## Dynamic Configuration

In this demo, the Configuration target from the example project is bespoke code. It actually embeds the configuration as a dictionary inside itself, and returns it as JSON when run.

This is the complete source for it:

```swift
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
```

This illustrates the fact that the configuration is actually being generated dynamically (by running code) and therefore could change based on the environment it's run in.

In this case it just returns a *static* dictionary, albeit one who's contents are varied at compile time depending on the platform. In theory though the content could also be varied based on runtime values.

This might lead you to think that bespoke configuration would be required every time.

However, there's no reason in principle why this Configuration target itself could not be derived from behaviour provided by another dependency, and thus completely re-usable.

For example, one strategy could just be to look for a file called `Configuration.json` in the working directory and return the contents of that. Someone could implement a configuration module `JSONConfiguration` which does that.

Then the entire `Configuration.swift` file of our module might just consist of:

```swift
import JSONConfiguration
JSONConfiguration.run()
```

In this way, it should be possible for this system to operate with the absolute minimum of code needing to be written for simple cases - whilst still allowing infinite complexity when required.


## Caveats

I hacked this together as a demo. It builds on MacOS and Linux, for me - your mileage may vary.

Lots of things have been glossed over, including:

- passing in useful environment to the helper executables (Configure and Tool)
- building/running the tool executables from sub-dependencies -- in principle this should be fine I think, I just wanted to keep the demo self-contained
- niceties such as error checking, help, etc, etc...
- running different tools, or using different configurations, for each product
- generating a fully-functional xcode project with
  - dependencies and sub-projects to build the tools
  - an xcconfig file built from the settings, applied to the products
  - build phases to run the tools as part of the build (this is tricky, but by no means impossible)
- the configuration and tool items are defined as targets, but built/run as products. This seems to work but is probably unsupported behaviour.

## Other Ideas

### Integration

As mentioned above, this is a prototype, so it's a standalone tool.

In theory though it would be integrated into `swift` itself. It could possibly even replace the existing `build` tool, with that being renamed to something lower-level which it could call on to, so that invoking `swift build` would run this tool. If no Configuration target was present in the manifest, we could fall back to the previous `swift build` behaviour.


### Package.swift

This prototype makes no changes to the `Package.swift` format. Because of this, the configuration and tool targets are just listed in the manifest along with the targets from the package that we're building.

This is potentially confusing, so an improvement to the design might be to change the DSL slightly to allow the special targets to be listed explicitly, like so:

```swift

let package = Package(
    name: "Example",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "Example",
            targets: ["Example"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    configuration:[
      .configurationTarget(
        name: "Configure",
        dependencies: []),
      .toolTarget(
        name: "Tool",
        dependencies: [])
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Example",
            dependencies: []),
        .testTarget(
            name: "ExampleTests",
            dependencies: ["Example"]),
    ]
)
```

I suspect that this would be preferable, but I wanted to start with something that didn't require modifying spm itself.

### Custom Build Phases

For simplicity, I went for a fixed order:

- run pre-build tools
- build products
- run post-build tools

This is perhaps a little inflexible.

There's no reason why the product build commands couldn't be interleaved with other tool executions, so the whole configuration just becomes some settings and a list of phases to execute:

```
let configuration : [String:Any] = [
    "settings" : settings,
    "phases" : [
      "run tool1",
      "build product1",
      "run tool2",
      "build product2",
      "run tool3"
      ],
]
```

Some special commands could be implemented by builder itself (eg "build" might trigger a build via `sketch build`).

Any other commands would be expected to correspond to tool target names, and would be built & run.
