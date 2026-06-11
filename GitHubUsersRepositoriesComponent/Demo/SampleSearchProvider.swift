//
//  SampleSearchProvider.swift
//  GitHubUsersRepositoriesComponent
//
//  In-memory SearchProviding for the demo and SwiftUI previews. It lets
//  every state be exercised without the network: a query containing
//  "empty" returns nothing and one containing "error" throws.
//

import Foundation

struct SampleSearchProvider: SearchProviding {
    /// Simulated network latency so the loading state is visible
    var delay: Duration = .milliseconds(500)

    func search(_ query: String) async throws -> [SearchResult] {
        try await Task.sleep(for: delay)

        if query.localizedCaseInsensitiveContains("error") {
            throw SampleError.simulated
        }
        if query.localizedCaseInsensitiveContains("empty") {
            return []
        }

        return Self.sample.sorted { $0.sortKey < $1.sortKey }
    }

    enum SampleError: LocalizedError {
        case simulated
        var errorDescription: String? { "Simulated failure for testing the error state." }
    }
}

extension SampleSearchProvider {
    /// A mix of users and repositories whose names interleave
    /// alphabetically, so the merged sort is easy to see
    static let sample: [SearchResult] = [
        SearchResult(id: "repo-1", kind: .repository, title: "Alamofire", subtitle: "Alamofire", avatarURL: nil, htmlURL: nil),
        SearchResult(id: "user-1", kind: .user, title: "apple", subtitle: nil, avatarURL: nil, htmlURL: nil),
        SearchResult(id: "repo-2", kind: .repository, title: "Charts", subtitle: "danielgindi", avatarURL: nil, htmlURL: nil),
        SearchResult(id: "user-2", kind: .user, title: "johnsundell", subtitle: nil, avatarURL: nil, htmlURL: nil),
        SearchResult(id: "repo-3", kind: .repository, title: "Kingfisher", subtitle: "onevcat", avatarURL: nil, htmlURL: nil),
        SearchResult(id: "user-3", kind: .user, title: "pointfreeco", subtitle: nil, avatarURL: nil, htmlURL: nil),
        SearchResult(id: "repo-4", kind: .repository, title: "SwiftUI", subtitle: "apple", avatarURL: nil, htmlURL: nil),
    ]
}
