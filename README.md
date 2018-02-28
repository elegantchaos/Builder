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
- uses the output of this run to configure the build of Example itself:
  - applies the returned compiler settings
  - builds & runs any pre-build tools
  - builds the specified targets
  - builds & runs any post-build tools
- runs the built output

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
