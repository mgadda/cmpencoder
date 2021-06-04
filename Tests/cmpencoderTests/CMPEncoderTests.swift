import XCTest
@testable import CMPEncoder

class cmpencoderTests: XCTestCase {
  func testRoundtripString() {      
    let encoder = CMPEncoder()
    encoder.write("Hello, World!")
    let decoder = CMPDecoder(from: encoder.buffer)
    XCTAssertEqual(try decoder.read(), "Hello, World!")
  }
}
