//
//  WithPairFetcher.swift
//  
//
//  Created by shun uematsu on 2023/02/25.
//

import SwiftUI

struct Pair<C0: Equatable, C1: Equatable>: Equatable {
  var c0: C0
  var c1: C1
  var tuple: (C0, C1) { (c0, c1) }
}

public struct WithPairFetcher<
  C0: EndpointProtocol,
  C1: EndpointProtocol,
  E,
  Success: View,
  Failure: View
>: View where E: Error, E: Equatable {
  @State private var loadingState: LoadState<Pair<C0.ResponseType, C1.ResponseType>, E> = .idle
  @Binding private var refresh: Bool

  private let first: C0
  private let second: C1
  private let environment: SideEffectEnvironment
  private let skelton: (C0.ResponseType, C1.ResponseType)
  private let loadedContent: ((C0.ResponseType, C1.ResponseType)) -> Success
  private let failedContent: (E) -> Failure

  public init(
    first: C0,
    second: C1,
    environment: SideEffectEnvironment,
    refresh: Binding<Bool>,
    skelton: (C0.ResponseType, C1.ResponseType),
    @ViewBuilder loadedContent: @escaping ((C0.ResponseType, C1.ResponseType)) -> Success,
    @ViewBuilder failedContent: @escaping (E) -> Failure
  ) {
    self.first = first
    self.second = second
    self.environment = environment
    self._refresh = refresh
    self.skelton = skelton
    self.loadedContent = loadedContent
    self.failedContent = failedContent
  }

  public var body: some View {
    ZStack {
      switch loadingState {
      case .idle:
        EmptyView()
      case .loading(let data), .loaded(let data):
        if let data {
          let redaction: RedactionReasons = loadingState == .loading(fake: data) ? .placeholder : []
          let disable = loadingState == .loading(fake: data)
          loadedContent(data.tuple)
            .redacted(reason: redaction)
            .transition(.opacity)
            .disabled(disable)
            .onChange(of: refresh) {
              guard $0 else { return }
              Task { await request(first: first, second: second) }
            }
        } else {
          EmptyView()
        }
      case .failed(let error):
        failedContent(error)
      }
    }
    .task { await request(first: first, second: second) }
    .animation(.default, value: loadingState)
  }
}

private extension WithPairFetcher {
  func request(first: C0, second: C1) async {
    guard loadingState == .idle || refresh else { return }
    loadingState = .loading(fake: Pair(c0: skelton.0, c1: skelton.1))
    do {
      async let a: C0.ResponseType = first.run(with: environment)
      async let b: C1.ResponseType = second.run(with: environment)
      let result = try await (a, b)
      loadingState = .loaded(data: .init(c0: result.0, c1: result.1))
    } catch {
      loadingState = .failed(error: error as! E)
    }
    refresh = false
  }
}
