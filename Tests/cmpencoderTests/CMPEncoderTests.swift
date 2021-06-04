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
}
