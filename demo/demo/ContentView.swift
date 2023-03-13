//
//  ContentView.swift
//  demo
//
//  Created by shun uematsu on 2023/02/18.
//

import declarative_fetcher
import SwiftUI

struct ContentView: View {
  var body: some View {
    List {
      NavigationLink("WithFetcher") {
        WithFetcherPage()
      }

      NavigationLink("WithPairFetcher") {
        WithPairFetcherPage()
      }

      NavigationLink("WithTripleFetcher") {
        WithTripleFetcherPage()
      }

      NavigationLink("Fetcher") {
        FetcherPage()
      }
    }
  }
}
