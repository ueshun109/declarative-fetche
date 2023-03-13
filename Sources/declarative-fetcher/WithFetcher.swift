//
//  WithFether.swift
//
//
//  Created by shun uematsu on 2023/02/25.
//

import SwiftUI

public struct WithFether<
  E,
  Endpoint: EndpointProtocol,
  Success: View,
  Failure: View
>: View where E: Error, E: Equatable {
  @State private var loadingState: LoadState<Endpoint.ResponseType, E> = .idle
  @Binding private var refresh: Bool

  private let endPoint: Endpoint
  private let environment: SideEffectEnvironment
  private let failedContent: (E) -> Failure
  private let loadedContent: (Endpoint.ResponseType) -> Success
  private let skelton: Endpoint.ResponseType

  public init(
    endPoint: Endpoint,
    environment: SideEffectEnvironment,
    refresh: Binding<Bool> = .constant(false),
    skelton: Endpoint.ResponseType,
    @ViewBuilder loadedContent: @escaping (Endpoint.ResponseType) -> Success,
    @ViewBuilder failedContent: @escaping (E) -> Failure
  ) {
    self.endPoint = endPoint
    self.environment = environment
    self.failedContent = failedContent
    self.loadedContent = loadedContent
    self._refresh = refresh
    self.skelton = skelton
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
          loadedContent(data)
            .redacted(reason: redaction)
            .transition(.opacity)
            .disabled(disable)
            .onChange(of: refresh) {
              guard $0 else { return }
              Task { await request(api: endPoint) }
            }
        } else {
          EmptyView()
        }
      case .failed(let error):
        failedContent(error)
      }
    }
    .task { await request(api: endPoint) }
    .animation(.default, value: loadingState)
  }
}

private extension WithFether {
  func request(api: Endpoint) async {
    guard loadingState == .idle || refresh else { return }
    loadingState = .loading(fake: skelton)
    do {
      let data: Endpoint.ResponseType = try await api.run(with: environment)
      loadingState = .loaded(data: data)
    } catch {
      loadingState = .failed(error: error as! E)
    }
    refresh = false
  }
}
