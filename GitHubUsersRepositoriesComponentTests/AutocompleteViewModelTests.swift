//
//  AutocompleteViewModelTests.swift
//  GitHubUsersRepositoriesComponentTests
//
//  Behavior of the generic autocomplete view model: the minimum-length
//  gate and the state it drives for success, empty, and error.
//

import Testing
import Foundation
@testable import GitHubUsersRepositoriesComponent

@MainActor
struct AutocompleteViewModelTests {

    @Test func belowMinimumLengthDoesNotSearch() async {
        let mock = MockSearchProvider()
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "sw"
        await Task.yield()

        #expect(mock.receivedQueries.isEmpty)
        #expect(viewModel.state == .idle)
    }

    @Test func droppingBelowMinimumReturnsToIdle() async {
        let mock = MockSearchProvider(response: .success([.fixture(title: "swift")]))
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "swift"
        await viewModel.waitUntilSettled()
        #expect(viewModel.state == .results([.fixture(title: "swift")]))

        viewModel.query = "sw"
        #expect(viewModel.state == .idle)
    }

    @Test func successfulSearchProducesResults() async {
        let results: [SearchResult] = [
            .fixture(id: "user-1", title: "apple"),
            .fixture(id: "repo-1", kind: .repository, title: "SwiftUI")
        ]
        let mock = MockSearchProvider(response: .success(results))
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "swift"
        await viewModel.waitUntilSettled()

        #expect(mock.receivedQueries == ["swift"])
        #expect(viewModel.state == .results(results))
    }

    @Test func emptyResultsProduceEmptyState() async {
        let mock = MockSearchProvider(response: .success([]))
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "zzzznomatch"
        await viewModel.waitUntilSettled()

        #expect(viewModel.state == .empty)
    }

    @Test func thrownErrorProducesErrorState() async {
        let mock = MockSearchProvider(response: .failure(SampleError.boom))
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "swift"
        await viewModel.waitUntilSettled()

        guard case .error = viewModel.state else {
            Issue.record("Expected error state, got \(viewModel.state)")
            return
        }
    }

    @Test func queryTrimsWhitespaceBeforeGating() async {
        let mock = MockSearchProvider()
        let viewModel = AutocompleteViewModel(provider: mock, debounceInterval: .zero)

        viewModel.query = "  a  "
        await Task.yield()

        #expect(mock.receivedQueries.isEmpty)
        #expect(viewModel.state == .idle)
    }
}
