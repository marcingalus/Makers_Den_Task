//
//  DemoScreen.swift
//  GitHubUsersRepositoriesComponent
//
//  Hosts the reusable autocomplete component against the live GitHub
//  service. It owns the view model, picks the data source, and provides
//  the per-row UI; the component itself stays unaware of GitHub.
//

import SwiftUI

struct DemoScreen: View {
    @State private var viewModel = AutocompleteViewModel(provider: GitHubSearchService())

    var body: some View {
        NavigationStack {
            AutocompleteView(viewModel: viewModel, prompt: "Search users and repositories") { result in
                SearchResultRow(result: result)
            }
            .navigationTitle("GitHub Search")
        }
    }
}

#Preview {
    // Offline preview backed by in-memory sample data
    NavigationStack {
        AutocompleteView(viewModel: AutocompleteViewModel(provider: SampleSearchProvider())) { result in
            SearchResultRow(result: result)
        }
        .navigationTitle("GitHub Search")
    }
}
