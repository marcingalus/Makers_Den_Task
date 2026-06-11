//
//  TestSupport.swift
//  GitHubUsersRepositoriesComponentTests
//
//  Shared fixtures and async helpers for the view model tests.
//

import Foundation
@testable import GitHubUsersRepositoriesComponent

extension SearchResult {
    /// Convenience fixture builder
    static func fixture(id: String = "user-1", kind: Kind = .user, title: String) -> SearchResult {
        SearchResult(id: id, kind: kind, title: title, subtitle: nil, avatarURL: nil, htmlURL: nil)
    }
}

@MainActor
extension AutocompleteViewModel {
    /// Polls until the state is no longer `.loading`, or the timeout elapses.
    /// Lets the in-flight search task run to completion in tests.
    func waitUntilSettled(timeout: Duration = .seconds(2)) async {
        let clock = ContinuousClock()
        let start = clock.now
        while case .loading = state, clock.now - start < timeout {
            try? await Task.sleep(for: .milliseconds(2))
        }
    }
}
