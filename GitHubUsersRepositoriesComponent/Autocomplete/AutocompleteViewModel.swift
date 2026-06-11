//
//  AutocompleteViewModel.swift
//  GitHubUsersRepositoriesComponent
//
//  Drives the autocomplete component: holds the query, enforces the
//  minimum length, runs the search through any SearchProviding source,
//  and exposes a single observable state for the view to render.
//

import Foundation
import Observation

@MainActor
@Observable
final class AutocompleteViewModel<Provider: SearchProviding> {
    typealias Item = Provider.Item

    /// Minimum characters required before a search runs
    let minimumQueryLength: Int

    /// How long to wait after the last keystroke before searching
    let debounceInterval: Duration

    /// The text the user is searching for; changing it triggers a search
    var query: String = "" {
        didSet {
            // Ignore no-op assignments (e.g. `.searchable` re-setting the
            // same text when editing ends) so we don't re-run the search
            guard query != oldValue else { return }
            search(for: query)
        }
    }

    /// What the view should currently render
    private(set) var state: AutocompleteState<Item> = .idle

    private let provider: Provider
    private var searchTask: Task<Void, Never>?

    init(
        provider: Provider,
        minimumQueryLength: Int = 3,
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.provider = provider
        self.minimumQueryLength = minimumQueryLength
        self.debounceInterval = debounceInterval
    }

    isolated deinit {
        searchTask?.cancel()
    }

    /// Starts a search for `text`, replacing any in-flight one
    func search(for text: String) {
        searchTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumQueryLength else {
            state = .idle
            return
        }

        state = .loading
        searchTask = Task { [weak self] in
            await self?.runSearch(trimmed)
        }
    }

    private func runSearch(_ text: String) async {
        do {
            // Wait out the debounce window; a newer keystroke cancels us
            // here, before we ever touch the provider
            try await Task.sleep(for: debounceInterval)
            let items = try await provider.search(text)
            guard !Task.isCancelled else { return }
            state = items.isEmpty ? .empty : .results(items)
        } catch is CancellationError {
            // Superseded by a newer search; let that one own the state
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }
}
