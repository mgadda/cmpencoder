//
//  Extensions.swift
//
//  Created by Matt Gadda on 12/2/17.
//
import Foundation

extension Data : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}

extension String : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = try decoder.read()
  }
}

extension Bool : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = try decoder.read()
  }
}

extension Float : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = try decoder.read()
  }
}


extension Double : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}

extension Int : MsgPackSerializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}
