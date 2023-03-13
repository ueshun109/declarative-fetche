import declarative_fetcher

enum DemoEndpoint<T: Codable>: EndpointProtocol where T: Equatable {
  case get(Get)

  enum Get {
    case school
    case students
    case teachers
  }

  func run(with environment: SideEffectEnvironment) async throws -> T {
    switch self {
    case .get(let get):
      switch get {
      case .school:
        return try await get.school(environment: environment) as! T
      case .students:
        return try await get.students(environment: environment) as! T
      case .teachers:
        return try await get.teachers(environment: environment) as! T
      }
    }
  }
}

private extension DemoEndpoint.Get {
  func school(environment: SideEffectEnvironment) async throws -> School {
    try! await Task.sleep(nanoseconds: 1_000_000_000)
    switch environment {
    case .live:
      return Bool.random() ? .fake : .fake2
    case .mock:
      return .fake
    case .failed:
      throw LoadError()
    }
  }

  func students(environment: SideEffectEnvironment) async throws -> [Student] {
    try! await Task.sleep(nanoseconds: 1_000_000_000)
    switch environment {
    case .live:
      return .fakes
    case .mock:
      return .fakes
    case .failed:
      throw LoadError()
    }
  }

  func teachers(environment: SideEffectEnvironment) async throws -> [Teacher] {
    try! await Task.sleep(nanoseconds: 1_000_000_000)
    switch environment {
    case .live:
      return .fakes
    case .mock:
      return .fakes
    case .failed:
      throw LoadError()
    }
  }
}
