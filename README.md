# Builder

The Swift Package Manager is cool, but rather basic.

It currently doesn't support running scripts or other tools as part of the build, or have a way to specify configuration settings.

This is a very simple proof-of-concept implementation of a meta-build command for the Swift Package Manager, which illustrates one way that these features could be added. It was originally inspired by [a discussion in the Swift forums](https://forums.swift.org/t/spm-static-dependencies/10152/35?u=samdeane).

The Builder executable built by this package is intended to be used _to build other Swift Package Manager packages_.

An example package is provided (in the `Example/` folder), which you can run Builder on.

The approach taken was deliberately chosen to work with the _current_ abilities of spm, so that the prototype could be a standalone tool that sits _on top of_ spm and uses it.

A real implementation could be integrated into spm itself, or could continue as a layer on top of it. The main advantage of integration is just that there's no extra tool to have to install.

Please leave comments and suggestions on the Swift forums, or as [issues in github](https://github.com/elegantchaos/Builder/issues).


### Instructions

To build & test Builder:

```
swift package update
cd Example
swift run --package-path ../. --static-swift-stdlib -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
.build/debug/Example
```

What this does is to build and run the Builder tool itself, which then builds the Example package.

Finally, the script runs the built example product.


## Discussion

Builder works by looking for a special target called `Configure` in the package that it's trying to build (defined in the `Package.swift` file).

If it finds this target, it uses `swift build` and/or `swift run` to do the following:

- build the Configure target
- run the resulting executable and capture its output
- parse this output to obtain a configuration to use to build the actual package
- build & run any pre-build tools specified by the configuration
- build the products listed in the configuration, applying any build settings from the configuration
- build & run any post-build tools listed in the configuration

The idea behind this approach is that:

- by moving the code for calculating the configuration into its own swift executable, it should be possible to eliminate any non-deterministic swift from the manifest
- any dependencies required to determine the configuration can be listed in the manifest as dependencies of the Configure target, and will be fetched and built in the normal way
- any tools required for custom build steps can also be listed in the manifest as dependencies
- although the data format output by the configuration tool needs to be fixed, the actual implementation of it is decoupled from swift itself, making it easier to support multiple different systems

If this functionality was built into `swift`, then for many cases it would be sufficient to completely define not only the package but how to build it.

The entire chain of build dependencies, including additional tools (such as `mogenerator`, `protobuf`, etc), can be fetched and built locally by the package manager itself.

This is intended to encourage, as much as possible, people to stay platform-neutral within the Swift ecosystem.

It also makes it simple for people to share re-usable build tools, since they're just Swift packages - hopefully this would result in a range of tools to suit most needs, so the requirement to actually write bespoke code would be minimal.

Of course, if you *do* have special requirements, such as tools that need to be installed or run with `brew`/`apt-get`/`npm`/`whatever`, then that's no problem either. Since you can now build and run arbitrary executables as part of the build process, you can use one to do anything that you need to.

## Dynamic Configuration

In this demo, the `Configure` target from the example project looks like this:

```swift
import BuilderBasicConfigure

#if os(macOS)
  let settings = ["target" : "x86_64-apple-macosx10.12"]
#else
  let settings : [String:String] = [:]
#endif

let configuration : [String:Any] = [
    "settings" : settings,
    "prebuild" : ["BuilderToolExample"],
    "products" : ["Example"],
    "postbuild" : ["BuilderToolExample"]
]

let configure = BasicConfigure(dictionary: configuration)
try configure.run()
```

As a relatively simple example, it actually embeds the configuration as a dictionary inside itself, and uses a class _from a dependency_  (defined in a different git repo, and listed as a dependency in the manifest for the `Example` package) to output it.

This dictionary supplies some build settings, and states that the `BuilderToolExample` tool should be run before and after building the `Example` product.

This `BuilderToolExample` tool is itself is another external dependency.

This code hopefully illustrates the fact that we can fetch, compile and run arbitrary tools as part of the overall build process.

It also demonstrates that the configuration can be generated dynamically (by running code, including external dependencies) and therefore could change based on the environment it's run in.

In this case it just returns a *static* dictionary, albeit one who's contents are varied at compile time depending on the platform. In theory though the content could also be varied based on runtime values, fetched from the network, loaded from disk, etc.


## Caveats

I hacked this together as a demo. It builds for me on MacOS and Linux - your mileage may vary.

Lots of things have been glossed over, including:

- passing in useful environment to the helper tools (Configure and Tool)
- niceties such as error checking, help, etc, etc...
- running different tools, or using different configurations, for each product
- generating a fully-functional xcode project with
  - dependencies and sub-projects to build the tools
  - an xcconfig file built from the settings, applied to the products
  - build phases to run the tools as part of the build (this is tricky, but by no means impossible)
- the configuration and tool items are defined as targets, but built/run as products. This seems to work but is probably unsupported behaviour.

## Other Ideas

### Integration

As mentioned above, this is a prototype, so for ease of development I made it a standalone tool rather than trying to modify `spm` itself.

In theory though it would be integrated into the `swift` command. It could possibly even replace the existing `swift-build` tool (with that being renamed to something else so that this tool could use it). Invoking `swift build` would then run this tool (if no Configuration target was present in the manifest, we could fall back to the previous `swift build` behaviour).

### Package.swift

This prototype is an overlay on `spm`, so makes no changes to the `Package.swift` format. Because of this, the configuration and tool targets are just listed in the manifest along with the targets from the package that we're building.

This is potentially confusing, a properly integrated implementation might change the format slightly to allow the special targets to be listed explicitly, like so:

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
        .package(url: "https://github.com/elegantchaos/BuilderToolExample.git", from: "1.0.3"),
    ],
    configuration:[
      .configurationTarget(
        name: "Configure",
        dependencies: ["BuilderToolExample"]),
      .toolTarget(
        name: "BuilderToolExample",
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

### Separate Package File

Rather than living in the main `Package.swift` file, the configuration and tool information could live in its own file which lived alongside the main one.

It could either have a standard name such as `Configure.swift` (which would require changes to spm), or it could live in a sub-folder, such as `Configure/Package.swift`.


### Custom Build Phases

For simplicity, I went for a fixed order:

- run pre-build tools
- build products
- run post-build tools

This is perhaps a little inflexible.

There's no reason why the product build commands couldn't be interleaved with other tool executions, so the whole configuration just becomes some settings and a list of phases to execute:

```
let configuration : [String:Any] = [
    "settings" : ["key" : "value"],
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
