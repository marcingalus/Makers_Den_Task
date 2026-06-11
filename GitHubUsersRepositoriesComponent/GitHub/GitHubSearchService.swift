//
//  GitHubSearchService.swift
//  GitHubUsersRepositoriesComponent
//
//  Concrete SearchProviding backed by GitHub. Fetches matching users and
//  repositories concurrently, flattens both into SearchResult, then
//  merges them into a single alphabetically sorted list.
//

import Foundation

struct GitHubSearchService: SearchProviding {
    private let client: GitHubAPIClient
    private let resultsPerPage: Int

    init(configuration: GitHubConfiguration = GitHubConfiguration(), session: URLSession = .shared) {
        self.client = GitHubAPIClient(session: session, configuration: configuration)
        self.resultsPerPage = configuration.resultsPerPage
    }

    func search(_ query: String) async throws -> [SearchResult] {
        // Both requests run concurrently; if one throws, the other is
        // cancelled and the error propagates to the caller
        async let users = fetchUsers(matching: query)
        async let repositories = fetchRepositories(matching: query)

        let combined = try await users + repositories
        return combined.sorted { $0.sortKey.localizedCompare($1.sortKey) == .orderedAscending }
    }

    private func fetchUsers(matching query: String) async throws -> [SearchResult] {
        let response: GitHubSearchResponse<GitHubUser> = try await client.get(
            .searchUsers(query: query, perPage: resultsPerPage)
        )
        return response.items.map(SearchResult.init(user:))
    }

    private func fetchRepositories(matching query: String) async throws -> [SearchResult] {
        let response: GitHubSearchResponse<GitHubRepository> = try await client.get(
            .searchRepositories(query: query, perPage: resultsPerPage)
        )
        return response.items.map(SearchResult.init(repository:))
    }
}
