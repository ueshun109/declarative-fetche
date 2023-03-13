//
//  FetcherPage.swift
//  demo
//
//  Created by shun uematsu on 2023/02/25.
//

import declarative_fetcher
import SwiftUI

struct FetcherPage: View {
  @State private var refresh = false
  @State private var schoolsRefresh = false
  @State private var school: LoadState<School, LoadError> = .idle

  var body: some View {
    WithPairFetcher(
      first: DemoEndpoint.get(.students),
      second: DemoEndpoint.get(.teachers),
      environment: .live,
      refresh: $refresh,
      skelton: (.fakes, .fakes)
    ) { (students: [Student], teachers: [Teacher]) in
      if let school = school.data {
        VStack(alignment: .leading, spacing: 16) {
          list(students: students, teachers: teachers)
          title(school: school)
            .padding(.horizontal, 16)
        }
      } else {
        Text("error")
      }
    } failedContent: { (error: LoadError) in
      Text("error")
    }
    .navigationTitle(school.data?.name ?? "")
    .fetch(
      from: DemoEndpoint.get(.school),
      refresh: $schoolsRefresh,
      state: $school
    )
  }

  func title(school: School) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(school.name)
        .font(.title)
      Text(school.address)
        .font(.subheadline)
        .foregroundColor(.gray)
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
    .refreshable {
      refresh = true
      schoolsRefresh = true
    }
  }

  func listItem(student: Student) -> some View {
    HStack(spacing: 4) {
      Text(student.firstName)
      Text(student.lastName)
    }
  }
}

struct FetcherPage_Previews: PreviewProvider {
  static var previews: some View {
    FetcherPage()
  }
}
