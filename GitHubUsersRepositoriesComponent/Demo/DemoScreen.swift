//
//  DemoScreen.swift
//  GitHubUsersRepositoriesComponent
//
//  Hosts the reusable autocomplete component. It owns the view model,
//  picks the data source, and provides the per-row UI. Right now it
//  runs against an in-memory sample provider; it will switch to the
//  live GitHub service without any change to the component itself.
//

import SwiftUI

struct DemoScreen: View {
    @State private var viewModel = AutocompleteViewModel(provider: SampleSearchProvider())

    var body: some View {
        NavigationStack {
            AutocompleteView(viewModel: viewModel, prompt: "Search users and repositories") { result in
                row(for: result)
            }
            .navigationTitle("GitHub Search")
        }
    }

    private func row(for result: SearchResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.kind == .user ? "person.circle" : "folder")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                if let subtitle = result.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    DemoScreen()
}
