//
//  WithFetcherPage.swift
//  demo
//
//  Created by shun uematsu on 2023/02/25.
//

import declarative_fetcher
import SwiftUI

struct WithFetcherPage: View {
  @State private var refresh = false

  var body: some View {
    WithFether(
      endPoint: DemoEndpoint<[Student]>.get(.students),
      environment: .live,
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

struct WithFetcherPage_Previews: PreviewProvider {
  static var previews: some View {
    WithFetcherPage()
  }
}
