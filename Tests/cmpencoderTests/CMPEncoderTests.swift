import XCTest
@testable import CMPEncoder

class cmpencoderTests: XCTestCase {
  func testRoundtripString() {      
    let encoder = CMPEncoder()
    encoder.write("Hello, World!")
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(try decoder.read(), "Hello, World!")
  }

  func testRoundtripArray() {
    let encoder = CMPEncoder()
    encoder.write([1,2,3,4])
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(try decoder.read(), [1,2,3,4])
  }

//  func testRoundtripDictionary() {
//    let encoder = CMPEncoder()
//    encoder.write([1: "value"])
//    let decoder = CMPDecoder(from: encoder.buffer)
//    XCTAssertEqual(try decoder.read(), [1: "value"])
//  }

  func testMultipleValues() {
    let encoder = CMPEncoder()
    encoder.write(1)
    encoder.write("2")
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(decoder.read(), 1)
    XCTAssertEqual(try decoder.read(), "2")
  }

  func testRoundtripBool() {
    let encoder = CMPEncoder()
    encoder.write(false)
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(decoder.read(), false)
  }

  func testRoundtripFloat() {
    let encoder = CMPEncoder()
    let v: Float = 0.25
    encoder.write(v)
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(decoder.read(), v)
  }

  func testRoundtripDouble() {
    let encoder = CMPEncoder()
    let v: Double = 0.25
    encoder.write(v)
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(decoder.read(), v)
  }

  func testRoundtripCustomType() {

    let f = Foo(a: 100, b: "bar")

    let encoder = CMPEncoder()
    encoder.write(f)
    let decoder = CMPDecoder(from: encoder.buffer)
    let decodedF: Foo = try! decoder.read(Foo.self)
    XCTAssertEqual(decodedF, f)
  }
}

struct Foo : Equatable {
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
