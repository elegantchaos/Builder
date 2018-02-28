# Builder

This is a very simple proof-of-concept implementation of a meta-build command for the Swift Package Manager, as described [in the Swift forums](https://forums.swift.org/t/spm-static-dependencies/10152/35?u=samdeane).

To build, use

```
swift package update
swift build
```

The resulting executable tool is intended to be used _to build other Swift Package Manager packages_.

An example project is provided.

To test the builder on it:

```
swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"
cd Example
../.build/debug/Builder
.build/debug/Example
```

What this does is to run Builder over the Example project, which:

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
