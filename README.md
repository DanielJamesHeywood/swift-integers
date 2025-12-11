# Swift Integers

**Swift Integers** is a package which implements `Integer`, a signed `BinaryInteger` with no fixed width, for the Swift programming language.

## Using Swift Integers

To use **Swift Integers** in a SwiftPM project:

1. Include **Swift Integers** in the dependencies of your package:

```swift
.package(url: "https://github.com/DanielJamesHeywood/swift-integers", from: "1.0.0"),
```

2. Include `Integers` in the dependencies of your target:

```swift
.product(name: "Integers", package: "swift-integers"),
```

3. Import `Integers` in your source code:

```swift
import Integers
```
