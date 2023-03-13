//
//  EndpointProtocol.swift
//
//
//  Created by shun uematsu on 2023/03/13.
//

public enum SideEffectEnvironment {
  case live
  case mock
  case failed
}

public protocol EndpointProtocol {
  associatedtype ResponseType: Codable, Equatable
  func run(with environment: SideEffectEnvironment) async throws -> ResponseType
}
