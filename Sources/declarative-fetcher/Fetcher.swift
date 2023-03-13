//
//  Fetcher.swift
//
//
//  Created by shun uematsu on 2023/02/25.
//

import SwiftUI

private struct Fetcher<E, Endpoint: EndpointProtocol>: ViewModifier where E: Error, E: Equatable {
  private let callback: ((Endpoint.ResponseType?, E?) -> Void)?
  private let condition: Bool
  private let endPoint: Endpoint
  private let environment: SideEffectEnvironment
  @Binding private var refresh: Bool
  @Binding private var state: LoadState<Endpoint.ResponseType, E>

  public init(
    callback: ((Endpoint.ResponseType?, E?) -> Void)?,
    condition: Bool,
    endPoint: Endpoint,
    environment: SideEffectEnvironment,
    refresh: Binding<Bool>,
    state: Binding<LoadState<Endpoint.ResponseType, E>>
  ) {
    self.callback = callback
    self.condition = condition
    self.endPoint = endPoint
    self.environment = environment
    self._refresh = refresh
    self._state = state
  }

  func body(content: Content) -> some View {
    content
      .onChange(of: refresh) {
        guard $0 else { return }
        Task {
          await request()
          refresh = false
        }
      }
      .onChange(of: condition) {
        guard $0 else { return }
        Task { await request() }
      }
      .task {
        guard condition else { return }
        await request()
      }
  }
}

private extension Fetcher {
  func request() async {
    do {
      let response: Endpoint.ResponseType = try await endPoint.run(with: environment)
      state = .loaded(data: response)
      callback?(response, nil)
    } catch {
      callback?(nil, error as? E)
      state = .failed(error: error as! E)
    }
  }
}

public extension View {
  /// 指定したエンドポイントからデータを取得するためのModifier
  ///
  ///     struct MyView: View {
  ///       @State private var state: Result<SampleData, Error> = .success(.fake)
  ///       var body: some View {
  ///         ZStack {
  ///           switch state {
  ///           case .success(let data):
  ///             Text(data.text)
  ///           case .failure(let error):
  ///             Text(error.localizedDescription)
  ///           }
  ///         }
  ///         .fetch(from: .anyEndpoint, state: $state)
  ///       }
  ///     }
  ///
  /// - Parameters:
  ///   - endPoint: エンドポイント
  ///   - condition: APIリクエストを実行するための条件
  ///   - environment: リクエストの実行環境
  ///   - refresh: 再取得の実行有無
  ///   - state: APIリクエストの結果を共有するための状態
  ///   - callback: 取得データとエラーのコールバック
  /// - Returns: `View`
  func fetch<E, Endpoint: EndpointProtocol>(
    from endPoint: Endpoint,
    condition: Bool = true,
    environment: SideEffectEnvironment = .live,
    refresh: Binding<Bool> = .constant(false),
    state: Binding<LoadState<Endpoint.ResponseType, E>> = .constant(.idle),
    callback: ((Endpoint.ResponseType?, Error?) -> Void)? = nil
  ) -> some View where E: Error, E: Equatable{
    modifier(
      Fetcher(
        callback: callback,
        condition: condition,
        endPoint: endPoint,
        environment: environment,
        refresh: refresh,
        state: state
      )
    )
  }
}
