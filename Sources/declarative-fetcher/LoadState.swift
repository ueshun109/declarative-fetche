//
//  LoadState.swift
//  
//
//  Created by shun uematsu on 2023/03/13.
//

public enum LoadState<T: Equatable, E>: Equatable where E: Error, E: Equatable {
   case idle
   case loading(fake: T? = nil)
   case loaded(data: T?)
   case failed(error: E)

  public var data: T? {
    switch self {
    case .idle, .failed: return nil
    case .loading(let data), .loaded(let data):
      return data
    }
  }
}
