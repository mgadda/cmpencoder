//
//  CMPEncoder.swift
//
//  Created by Matt Gadda on 10/28/17.
//
import Foundation
import CMP

func cmpWriter(ctx: UnsafeMutablePointer<cmp_ctx_s>!, data: UnsafeRawPointer!, count: Int) -> Int {
  let cmpJump = ctx.pointee.buf.bindMemory(to: CMPJump.self, capacity: 1).pointee
  if let encoder = cmpJump.encoder {
    return encoder.write(data, count)
  }
  return 0
}

func cmpSkipper(ctx: UnsafeMutablePointer<cmp_ctx_s>!, count: Int) -> Bool {
  let cmpJump = ctx.pointee.buf.bindMemory(to: CMPJump.self, capacity: 1).pointee
  if let encoder = cmpJump.encoder {
    return encoder.skip(count: count)
  } else if let decoder = cmpJump.decoder {
    return decoder.skip(count: count)
  }

  return false
}

func cmpReader(ctx: UnsafeMutablePointer<cmp_ctx_s>!, data: UnsafeMutableRawPointer!, limit: Int) -> Bool {
  let cmpJump = ctx.pointee.buf.bindMemory(to: CMPJump.self, capacity: 1).pointee
  if let decoder = cmpJump.decoder {
    return decoder.read(data, count: limit)
  }

  return false
}

struct CMPJump {
  var encoder: CMPEncoder?
  var decoder: CMPDecoder?
  init() {}
}

// TODO: why is this necessary?
public class CMPKeyedDecoderContainer {
  var container: [String : Serializable] = [:]
  public func write<T: Serializable>(key: String, value: T) {
    container[key] = value
  }
}

public class CMPEncoder {
  var context = cmp_ctx_t()
  public var buffer = Data()

  public let userContext: Any?

  var bufferPosition = 0 // used for reading/skipping
  var jump: CMPJump

  public init(userContext: Any? = nil) {
    self.userContext = userContext
    jump = CMPJump()
    jump.encoder = self
    // `this` is guaranteed to be as valid as long as `self`
    withUnsafeMutablePointer(to: &jump) { (ptr) -> Void in
      cmp_init(&context, ptr, nil, cmpSkipper, cmpWriter)
    }
  }

  func read(_ data: UnsafeMutableRawPointer, count: Int) -> Bool {
    let range: Range<Int> = bufferPosition..<(bufferPosition + count)
    buffer.copyBytes(to: data.bindMemory(to: UInt8.self, capacity: count), from: range)
    bufferPosition += count
    return true
  }

  /// Append data to CMPEncoder's internal buffer
  public func write(_ data: UnsafeRawPointer, _ count: Int) -> Int {
    // if this is too slow, we need to blit memory with copyBytes and using bufferPosition
    buffer.append(data.bindMemory(to: UInt8.self, capacity: count), count: count)
    return count
  }

  func skip(count: Int) -> Bool {
    bufferPosition += count
    return true
  }

  public func write(_ value: Int) {
    cmp_write_s64(&context, Int64(value))
  }

  public func write(_ value: Int64) {
    cmp_write_s64(&context, value)
  }

  public func write(_ value: Double) {
    cmp_write_double(&context, value)
  }

  public func write(_ value: Data) {
    value.withUnsafeBytes { ptr -> Void in
      cmp_write_bin(&context, ptr, UInt32(value.count))
    }
  }

  public func write<T: Serializable>(_ value: T) {
    value.serialize(encoder: self)
  }

  public func write<T: Serializable>(_ values: [T]) {
    cmp_write_array(&context, UInt32(values.count))
    values.forEach { value -> Void in
      value.serialize(encoder: self)
    }
  }

  public func write<T: Serializable>(_ values: [String : T?]) {
    cmp_write_map(&context, UInt32(values.count))
    values.forEach { (key, value) in
      guard value != nil else { return }
      key.serialize(encoder: self)
      value!.serialize(encoder: self)
    }
  }

  public func write(_ value: String) {
    let data = value.data(using: .utf8)!
    _ = data.withUnsafeBytes({ bytes in
      cmp_write_str(&context, bytes, UInt32(data.count))
    })
  }

  public func keyedContainer() -> CMPKeyedDecoderContainer {
    return CMPKeyedDecoderContainer()
  }

  public func write(_ value: CMPKeyedDecoderContainer) {
    cmp_write_map(&context, UInt32(value.container.count))
    value.container.forEach { key, value in
      write(key)
      value.serialize(encoder: self)
    }
  }
}

func cmpFileWriter(ctx: UnsafeMutablePointer<cmp_ctx_s>!, data: UnsafeRawPointer!, count: Int) -> Int {
  let fileHandlePtr = ctx.pointee.buf.bindMemory(to: FileHandle.self, capacity: 1)
  fileHandlePtr.pointee.write(Data(bytes: data, count: count))
  return count
}

func cmpFileSkipper(ctx: UnsafeMutablePointer<cmp_ctx_s>!, count: Int) -> Bool {
  let fileHandlePtr = ctx.pointee.buf.bindMemory(to: FileHandle.self, capacity: 1)
  fileHandlePtr.pointee.seek(toFileOffset: UInt64(count))
  return true
}

func cmpFileReader(ctx: UnsafeMutablePointer<cmp_ctx_s>!, data: UnsafeMutableRawPointer!, limit: Int) -> Bool {
  let fileHandlePtr = ctx.pointee.buf.bindMemory(to: FileHandle.self, capacity: 1)
  fileHandlePtr.pointee
    .readData(ofLength: limit)
    .copyBytes(to: data.bindMemory(to: UInt8.self, capacity: limit), count: limit)
  return true
}
