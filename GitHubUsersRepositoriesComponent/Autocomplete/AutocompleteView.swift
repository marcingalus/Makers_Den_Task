//
//  AutocompleteView.swift
//  GitHubUsersRepositoriesComponent
//
//  The reusable, domain-agnostic autocomplete UI. It renders a search
//  field plus the view model's state, but does not own the view model:
//  the host creates and holds it, this view only borrows it. Callers
//  supply only the row for a single item, so the same view works for
//  any data source.
//
//  Note: `.searchable` needs a NavigationStack (or split view) ancestor,
//  which the host screen provides.
//

import SwiftUI

struct AutocompleteView<Provider: SearchProviding, Row: View>: View {
    @Bindable var viewModel: AutocompleteViewModel<Provider>
    private let prompt: String
    private let row: (Provider.Item) -> Row

    init(
        viewModel: AutocompleteViewModel<Provider>,
        prompt: String = "Search",
        @ViewBuilder row: @escaping (Provider.Item) -> Row
    ) {
        self.viewModel = viewModel
        self.prompt = prompt
        self.row = row
    }

    var body: some View {
        content
            .searchable(text: $viewModel.query, prompt: prompt)
            .animation(.default, value: viewModel.state)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Start typing",
                systemImage: "magnifyingglass",
                description: Text("Enter at least \(viewModel.minimumQueryLength) characters to search.")
            )

        case .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .results(let items):
            List(items) { item in
                row(item)
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)

        case .empty:
            ContentUnavailableView.search

        case .error(let message):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    viewModel.search(for: viewModel.query)
                }
            }
        }
    }
}
