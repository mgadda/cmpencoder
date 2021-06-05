//
//  Serializable.swift
//
//  Created by Matt Gadda on 12/7/17.
//
public protocol MsgPackSerializable {
  func serialize(encoder: CMPEncoder)
//  static func deserialize(with decoder: CMPDecoder) -> Self
  init(with decoder: CMPDecoder) throws
}
