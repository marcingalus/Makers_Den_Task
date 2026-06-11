//
//  AutocompleteDebounceTests.swift
//  GitHubUsersRepositoriesComponentTests
//
//  Verifies the view model handles rapid input sensibly: bursts of
//  keystrokes collapse into a single search for the final query, and
//  a superseded search never reaches the provider.
//

import Testing
import Foundation
@testable import GitHubUsersRepositoriesComponent

@MainActor
struct AutocompleteDebounceTests {

    @Test func rapidInputIssuesSingleSearchForFinalQuery() async {
        let mock = MockSearchProvider(response: .success([.fixture(title: "swift")]))
        let viewModel = AutocompleteViewModel(
            provider: mock,
            debounceInterval: .milliseconds(50)
        )

        // Simulate fast typing: each keystroke supersedes the previous
        viewModel.query = "swi"
        viewModel.query = "swif"
        viewModel.query = "swift"

        await viewModel.waitUntilSettled()

        #expect(mock.receivedQueries == ["swift"])
    }

    @Test func searchSupersededDuringDebounceNeverHitsProvider() async {
        let mock = MockSearchProvider(response: .success([]))
        let viewModel = AutocompleteViewModel(
            provider: mock,
            debounceInterval: .milliseconds(50)
        )

        viewModel.query = "abc"
        // Replace it well within the debounce window
        viewModel.query = "abcd"

        await viewModel.waitUntilSettled()

        #expect(mock.receivedQueries == ["abcd"])
        #expect(mock.receivedQueries.count == 1)
    }
}
