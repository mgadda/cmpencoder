//
//  CMPDecoder.swift
//
//  Created by Matt Gadda on 12/2/17.
//
import Foundation
import CMP

public class CMPDecoder {
  var context = cmp_ctx_t()
  var buffer: Data
  public let userContext: Any?

  var bufferPosition = 0 // used for reading/skipping
  var jump: CMPJump

  public init(from buffer: Data, userContext: Any? = nil) {
    self.buffer = buffer
    self.userContext = userContext

    jump = CMPJump()
    jump.decoder = self

    // `this` is guaranteed to be as valid as long as `self`
    withUnsafeMutablePointer(to: &jump) { (ptr) -> Void in
      cmp_init(&context, ptr, cmpReader, cmpSkipper, nil)
    }

  }

  public func read(_ data: UnsafeMutableRawPointer, count: Int) -> Bool {
    let range: Range<Int> = bufferPosition..<(bufferPosition + count)
    buffer.copyBytes(to: data.bindMemory(to: UInt8.self, capacity: count), from: range)
    bufferPosition += count
    return true
  }

  func skip(count: Int) -> Bool {
    bufferPosition += count
    return true
  }

  public func read() -> Int {
    var value: Int64 = 0
    cmp_read_s64(&context, &value)

    // TODO: correctly handle decoding 64-bit ints on 32-bit systems
    return Int(value)
  }

  public func read() -> Int64 {
    var value: Int64 = 0
    cmp_read_s64(&context, &value)
    return value
  }

  public func read() -> Bool {
    var value: Bool = false
    cmp_read_bool(&context, &value)
    return value
  }

  public func read() -> Float {
    var value: Float = 0.0
    cmp_read_float(&context, &value)
    return value
  }

  public func read() -> Double {
    var value: Double = 0.0
    cmp_read_double(&context, &value)
    return value
  }

  public func read() -> Data {
    var size: UInt32 = 0
    freezingPosition { cmp_read_bin_size(&context, &size) }
    var value = Data(count: Int(size)) // TODO: potential data loss here for values > Int.max and < UInt32.max
    let _ = value.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) -> Bool in
      cmp_read_bin(&context, ptr, &size)
    }
    return value
  }

  func freezingPosition(fn: () -> Void) {
    let oldBufferPosition = bufferPosition
    fn()
    bufferPosition = oldBufferPosition
  }

  public func read() throws -> String {
    var size: UInt32 = 0
    freezingPosition { cmp_read_str_size(&context, &size) }
    size += 1 // cmp_read_str apparently expects this
    var value = Data(count: Int(size)) // TODO: potential data loss here for values > Int.max and < UInt32.max
    let result = value.withUnsafeMutableBytes { ptr in
      cmp_read_str(&context, ptr, &size)
    }

    if !result {
      throw CMPError.decodingError("Error code \(context.error)")
    }

    return String(data: value.subdata(in: 0..<(value.count - 1)), encoding: .utf8)!
  }

  /// Read a homoegeneous array of values
  public func read<T : MsgPackSerializable>() throws -> [T] {
    var size: UInt32 = 0
    cmp_read_array(&context, &size)
    return try Array((0..<size)).map { (_) -> T in
      try T(with: self)
    }
  }

  /// Read heterogeneous dictionary of Serializable values
  public func read(_ fields: [String : MsgPackSerializable.Type]) throws -> [String : Any] {
    var size: UInt32 = 0
    cmp_read_map(&context, &size)
    let keysAndValues = try Array((0..<size)).compactMap { (_) -> (String, MsgPackSerializable) in
      let key = try String(with: self)
      let value = (try fields[key]?.init(with: self))!
      return (key, value)
    }
    return Dictionary<String, MsgPackSerializable>(uniqueKeysWithValues: keysAndValues)
  }

  /// Deserialize a homogeneous map of String -> T (probably of limited utility)
  /// This method should not be confused with a type-less keyed decoding container
  public func read<T : MsgPackSerializable>() throws -> [String : T] {
    var size: UInt32 = 0
    cmp_read_map(&context, &size)
    let keysAndValues = try Array((0..<size)).compactMap { (_) -> (String, T) in
      (try String(with: self), try T(with: self))
    }
    return Dictionary<String, T>(uniqueKeysWithValues: keysAndValues)
  }

  public func read<T: MsgPackSerializable>(_ type: T.Type) throws -> T {
    return try T(with: self)
  }
}
