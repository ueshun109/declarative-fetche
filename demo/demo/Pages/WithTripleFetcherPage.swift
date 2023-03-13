//
//  WithTripleFetcherPage.swift
//  demo
//
//  Created by shun uematsu on 2023/02/25.
//

import declarative_fetcher
import SwiftUI

struct WithTripleFetcherPage: View {
  @State private var refresh = false

  var body: some View {
    WithTripleFetcher(
      first: DemoEndpoint<[Student]>.get(.students),
      second: DemoEndpoint<[Teacher]>.get(.teachers),
      third: DemoEndpoint<School>.get(.school),
      environment: .live,
      refresh: $refresh,
      skelton: (.fakes, .fakes, .fake)
    ) { students, teachers, school in
      VStack(alignment: .leading, spacing: 16) {
        list(students: students, teachers: teachers)
        title(school: school)
          .padding(.horizontal, 16)
      }
    } failedContent: { (error: LoadError) in
      Text("error")
    }
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
    .refreshable { refresh = true }
  }

  func listItem(student: Student) -> some View {
    HStack(spacing: 4) {
      Text(student.firstName)
      Text(student.lastName)
    }
  }
}

struct WithTripleFetcherPage_Previews: PreviewProvider {
  static var previews: some View {
    WithTripleFetcherPage()
  }
}
