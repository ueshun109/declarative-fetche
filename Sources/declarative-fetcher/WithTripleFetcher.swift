//
//  WithTripleFetcher.swift
//
//
//  Created by shun uematsu on 2023/02/25.
//

import SwiftUI

struct Triple<C0: Equatable, C1: Equatable, C2: Equatable>: Equatable {
  var c0: C0
  var c1: C1
  var c2: C2
  var tuple: (C0, C1, C2) { (c0, c1, c2) }
}

public struct WithTripleFetcher<
  C0: EndpointProtocol,
  C1: EndpointProtocol,
  C2: EndpointProtocol,
  E,
  Success: View,
  Failure: View
>: View where E: Error, E: Equatable {
  @State private var loadingState: LoadState<Triple<C0.ResponseType, C1.ResponseType, C2.ResponseType>, E> = .idle
  @Binding private var refresh: Bool

  private let first: C0
  private let second: C1
  private let third: C2
  private let environment: SideEffectEnvironment
  private let skelton: (C0.ResponseType, C1.ResponseType, C2.ResponseType)
  private let loadedContent: ((C0.ResponseType, C1.ResponseType, C2.ResponseType)) -> Success
  private let failedContent: (E) -> Failure

  public init(
    first: C0,
    second: C1,
    third: C2,
    environment: SideEffectEnvironment,
    refresh: Binding<Bool> = .constant(false),
    skelton: (C0.ResponseType, C1.ResponseType, C2.ResponseType),
    @ViewBuilder loadedContent: @escaping ((C0.ResponseType, C1.ResponseType, C2.ResponseType)) -> Success,
    @ViewBuilder failedContent: @escaping (E) -> Failure
  ) {
    self.first = first
    self.second = second
    self.third = third
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
              Task { await request(first: first, second: second, third: third) }
            }
        } else {
          EmptyView()
        }
      case .failed(let error):
        failedContent(error)
      }
    }
    .task { await request(first: first, second: second, third: third) }
    .animation(.default, value: loadingState)
  }
}

private extension WithTripleFetcher {
  func request(first: C0, second: C1, third: C2) async {
    guard loadingState == .idle || refresh else { return }
    loadingState = .loading(fake: Triple(c0: skelton.0, c1: skelton.1, c2: skelton.2))
    do {
      async let a: C0.ResponseType = first.run(with: environment)
      async let b: C1.ResponseType = second.run(with: environment)
      async let c: C2.ResponseType = third.run(with: environment)
      let result = try await (a, b, c)
      loadingState = .loaded(data: .init(c0: result.0, c1: result.1, c2: result.2))
    } catch {
      loadingState = .failed(error: error as! E)
    }
    refresh = false
  }
}
