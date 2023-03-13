# Declarative Fetcher
Fetch data via easily on SwiftUI.

Declarative Fetcher is convinience helper for retriving data via RestfulAPI.
Using this, you can fetch data easily.

# Motivation
When you use ResutlAPI to retrieve data, you are likely to use a procedural implementation like the following.

```swift
struct ImperativeCode: View {
  @State private var students: [Student] = []

  var body: some View {
    VStack {

    }.task {
      // 🤔 That’s kinda iffy.
      do {
        students = try await fetch()
      } catch {
        // Handle error
      }
    }
  }
}

```

But even if you are writing declarative code in SwiftUI, you do not want to add imperative code to it.
This is because data retrieval is a means to build the screen, not the essence.
We wanted to eliminate imperative code as much as possible on ui layer.
Therefore, we will allow you to write declarative code to retrieve data, so that you can concentrate on building the UI.

```swift
WithFether(
  endPoint: DemoEndpoint<[Student]>.get(.students),
  refresh: $refresh,
  skelton: .fakes
) { students in
  // 😀 You can only implement ui!
} failedContent: { error in
    Text("error")
}
```

# Usage
Assuming that data is to be retrieved via RestfulAPI, this section describes how to use.

## Define Endpoint
Define endpoint. You must implement [EndpointProtocol](https://github.com/ueshun109/declarative-fetche/blob/293996def51652ba50624395992ee7bac1480bdf/Sources/declarative-fetcher/EndpointProtocol.swift#L14).

```swift
enum DemoEndpoint<T: Codable>: EndpointProtocol where T: Equatable {
  func run(with environment: SideEffectEnvironment) async throws -> T {
    // Implement code to retrieve data.
  }
}
```

Basically, we expect to implement the code to retrieve the data here.
Check [here](https://github.com/ueshun109/declarative-fetche/blob/main/demo/demo/DataSource/DemoEndpoint.swift) for specific sample code.

## Create Fake model
Implement a fake code that displays a skeleton indicating that loading is in progress.

```swift
struct Student: Identifiable, Codable, Equatable {
  var id: Int
  var firstName: String
  var lastName: String
}

extension [Student] {
  static let fakes: [Student] = [
    .init(id: 1, firstName: "taro", lastName: "tanaka"),
    .init(id: 2, firstName: "hanako", lastName: "suzuki"),
    .init(id: 3, firstName: "ryo", lastName: "hashimoto"),
  ]
}
```

## Declare Fetcher
Declare `WithFether`or`fetch`modifier to fetch data.

### Using WithFethers
```swift
struct WithFetcherPage: View {
  @State private var refresh = false

  var body: some View {
    WithFether(
      endPoint: DemoEndpoint<[Student]>.get(.students),
      refresh: $refresh,
      skelton: .fakes
    ) { students in
      List {
        ForEach(students) { student in
          HStack(spacing: 4) {
            Text(student.firstName)
            Text(student.lastName)
          }
        }
      }
      .refreshable { refresh = true }
    } failedContent: { (error: LoadError) in
      Text("error")
    }
  }
}
```

### Using fetch modifier
```swift
struct FetchModifierPage: View {
  @State private var students: LoadState<[Student], LoadError> = .idle

  @ViewBuilder
  var body: some View {
    ZStack {
      if let students = students.data {
        List {
          ForEach(students) { student in
            HStack(spacing: 4) {
              Text(student.firstName)
              Text(student.lastName)
            }
          }
        }
      } else {
        ProgressView()
          .fetch(
            from: DemoEndpoint<[Student]>.get(.students),
            state: $students
          )
      }
    }
    .animation(.default, value: students)
  }
}
```

## Installation
You can add Declarative Fetcher to an Xcode project by adding it as a package dependency.

If you want to use Declarative Fetcher in a SwiftPM project, it's as simple as adding it to a dependencies clause in your Package.swift:

```
dependencies: [
  .package(url: "https://github.com/ueshun109/declarative-fetcher", from: "0.1.0")
]
```

## License
This library is released under the MIT license. See [LICENSE](https://github.com/ueshun109/declarative-fetcher/blob/main/LICENSE) for details.