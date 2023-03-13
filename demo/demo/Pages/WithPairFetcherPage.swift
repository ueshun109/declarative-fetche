//
//  WithPairFetcherPage.swift
//  demo
//
//  Created by shun uematsu on 2023/02/25.
//

import declarative_fetcher
import SwiftUI

struct WithPairFetcherPage: View {
  @State private var refresh: Bool = false

  var body: some View {
    WithPairFetcher(
      first: DemoEndpoint<[Student]>.get(.students),
      second: DemoEndpoint<[Teacher]>.get(.teachers),
      environment: .live,
      refresh: $refresh,
      skelton: (.fakes, .fakes)
    ) { students, teachers in
      list(students: students, teachers: teachers)
    } failedContent: { (error: LoadError) in
      Text("error")
    }
  }

  func list(students: [Student], teachers: [Teacher]) -> some View {
    List {
      ForEach(teachers) { teacher in
        Section {
          ForEach(students) { student in
            listItem(student: student)
          }
        } header: {
          HStack(spacing: 4) {
            Text(teacher.firstName)
            Text(teacher.lastName)
          }
          .font(.headline)
        }
      }
    }
    .refreshable { refresh = true }
  }

  func listItem(student: Student) -> some View {
    HStack(spacing: 4) {
      Text(student.firstName)
      Text(student.lastName)
    }
  }
}

struct WithPairFetcherPage_Previews: PreviewProvider {
  static var previews: some View {
    WithPairFetcherPage()
  }
}
