//
//  Extensions.swift
//
//  Created by Matt Gadda on 12/2/17.
//
import Foundation

extension Data : Serializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}

extension String : Serializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = try decoder.read()
  }
}

extension Double : Serializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}

extension Int : Serializable {
  public func serialize(encoder: CMPEncoder) {
    encoder.write(self)
  }
  public init(with decoder: CMPDecoder) throws {
    self = decoder.read()
  }
}