//
//  MockSearchProvider.swift
//  GitHubUsersRepositoriesComponentTests
//
//  A controllable SearchProviding for view model tests. Records the
//  queries it receives and returns canned results or a thrown error.
//

import Foundation
@testable import GitHubUsersRepositoriesComponent

@MainActor
final class MockSearchProvider: SearchProviding {
    enum Response {
        case success([SearchResult])
        case failure(Error)
    }

    var response: Response
    /// Every query passed to `search`, in order
    private(set) var receivedQueries: [String] = []

    init(response: Response = .success([])) {
        self.response = response
    }

    func search(_ query: String) async throws -> [SearchResult] {
        receivedQueries.append(query)
        switch response {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
}

enum SampleError: Error {
    case boom
}
