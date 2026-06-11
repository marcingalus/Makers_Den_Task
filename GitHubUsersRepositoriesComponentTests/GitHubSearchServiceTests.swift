//
//  GitHubSearchServiceTests.swift
//  GitHubUsersRepositoriesComponentTests
//
//  Exercises the GitHub service against stubbed responses: decoding,
//  merging users + repositories into one alphabetically sorted list,
//  the per-request limit, and rate-limit handling.
//

import Testing
import Foundation
@testable import GitHubUsersRepositoriesComponent

@Suite(.serialized)
struct GitHubSearchServiceTests {

    private let configuration = GitHubConfiguration(
        baseURL: URL(string: "https://api.github.test")!,
        token: nil
    )

    private func makeService() -> GitHubSearchService {
        GitHubSearchService(configuration: configuration, session: MockURLProtocol.makeSession())
    }

    @Test func mergesAndSortsUsersAndRepositoriesAlphabetically() async throws {
        MockURLProtocol.handler = { request in
            let data = request.url?.path.contains("/search/users") == true
                ? Self.usersJSON
                : Self.repositoriesJSON
            return (Self.ok(request), data)
        }

        let results = try await makeService().search("x")

        // Users (Bravo, Delta) and repos (alpha, charlie) interleave
        #expect(results.map(\.title) == ["alpha", "Bravo", "charlie", "Delta"])
        #expect(results.map(\.kind) == [.repository, .user, .repository, .user])
    }

    @Test func requestsConfiguredPageSize() async throws {
        MockURLProtocol.handler = { request in
            let perPage = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "per_page" }?.value
            #expect(perPage == "50")
            return (Self.ok(request), Self.emptyJSON)
        }

        _ = try await makeService().search("swift")
    }

    @Test func rateLimitedResponseThrowsRateLimited() async {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: ["X-RateLimit-Remaining": "0"]
            )!
            return (response, Data())
        }

        do {
            _ = try await makeService().search("swift")
            Issue.record("Expected the search to throw")
        } catch let error as GitHubError {
            guard case .rateLimited = error else {
                Issue.record("Expected .rateLimited, got \(error)")
                return
            }
        } catch {
            Issue.record("Expected GitHubError, got \(error)")
        }
    }
}

private extension GitHubSearchServiceTests {
    static func ok(_ request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static let usersJSON = Data("""
    {
      "total_count": 2,
      "incomplete_results": false,
      "items": [
        { "id": 1, "login": "Bravo", "avatar_url": "https://example.com/b.png", "html_url": "https://github.com/Bravo" },
        { "id": 2, "login": "Delta", "avatar_url": "https://example.com/d.png", "html_url": "https://github.com/Delta" }
      ]
    }
    """.utf8)

    static let repositoriesJSON = Data("""
    {
      "total_count": 2,
      "incomplete_results": false,
      "items": [
        { "id": 10, "name": "alpha", "full_name": "owner/alpha", "owner": { "login": "owner", "avatar_url": "https://example.com/a.png" }, "description": "a", "html_url": "https://github.com/owner/alpha" },
        { "id": 11, "name": "charlie", "full_name": "owner/charlie", "owner": { "login": "owner", "avatar_url": "https://example.com/c.png" }, "description": null, "html_url": "https://github.com/owner/charlie" }
      ]
    }
    """.utf8)

    static let emptyJSON = Data("""
    { "total_count": 0, "incomplete_results": false, "items": [] }
    """.utf8)
}
