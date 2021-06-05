# CMPEncoder
CMPEncoder provides a swift-friendly interface to [camgunz/cmp](https://github.com/camgunz/cmp) for encoding and decoding using the msgpack specification.

CMPEncoder is _very fast_ for which it deserves absolutely no credit. It uses the C-based [camgunz/cmp](https://github.com/camgunz/cmp) to perform encoding and decoding.

CMPEncoder is used in [zig](https://github.com/mgadda/zig) for all serialization/deserialization of data to/from its object database.

## Installation

Add the following to your dependencies in `Package.swift`:

```swift
.package(url: "https://github.com/mgadda/CMPEncoder.git", from: "0.1.0")
```

Then just `import CMPEncoder` as needed.

## Usage

### Encoding
```swift
let encoder = CMPEncoder()
encoder.write("Hello, World!")
// Your data is now available in `encoder.buffer`

```

### Decoding
```swift
let msgPackedData: Data = ...
let decoder = CMPDecoder(from: msgPackedData)
let str: String = try decoder.read()
```

### Round-trip custom type

Arbitrary custom types that conform to `MsgPackSerializable` can be serialized and 
deserialized.

```swift
struct Foo {
  let a: Int
  let b: String
}

extension Foo: MsgPackSerializable {
  func serialize(encoder: CMPEncoder) {
    encoder.write(a)
    encoder.write(b)
  }

  init(with decoder: CMPDecoder) throws {
    a = decoder.read()
    b = try decoder.read()
  }
}

let f = Foo(a: 100, b: "bar")
let encoder = CMPEncoder()
encoder.write(f)
let decoder = CMPDecoder(from: encoder.buffer)
let decodedFoo: Foo = try! decoder.read(Foo.self)
```
