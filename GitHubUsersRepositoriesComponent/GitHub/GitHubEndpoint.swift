//
//  GitHubEndpoint.swift
//  GitHubUsersRepositoriesComponent
//
//  Describes the GitHub Search endpoints we call and builds their URLs.
//  Keeping this separate keeps the API client free of path/query details.
//

import Foundation

enum GitHubEndpoint {
    case searchUsers(query: String, perPage: Int)
    case searchRepositories(query: String, perPage: Int)

    private var path: String {
        switch self {
        case .searchUsers: return "/search/users"
        case .searchRepositories: return "/search/repositories"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .searchUsers(query, perPage),
             let .searchRepositories(query, perPage):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
        }
    }

    /// Resolves the endpoint against a base URL (default: api.github.com)
    func url(baseURL: URL = URL(string: "https://api.github.com")!) -> URL? {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems
        return components?.url
    }
}
