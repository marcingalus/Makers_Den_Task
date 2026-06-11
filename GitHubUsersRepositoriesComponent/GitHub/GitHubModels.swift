//
//  GitHubModels.swift
//  GitHubUsersRepositoriesComponent
//
//  Decodable models mirroring the GitHub Search API responses
//  See: https://docs.github.com/en/rest/search
//

import Foundation

/// Generic envelope returned by every GitHub `/search/*` endpoint
struct GitHubSearchResponse<Item: Decodable>: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

/// A user (or organization) as returned by `/search/users`
struct GitHubUser: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let login: String
    let avatarURL: URL?
    let htmlURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

/// A repository as returned by `/search/repositories`
struct GitHubRepository: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let owner: Owner
    let description: String?
    let htmlURL: URL?

    struct Owner: Decodable, Equatable, Sendable {
        let login: String
        let avatarURL: URL?

        enum CodingKeys: String, CodingKey {
            case login
            case avatarURL = "avatar_url"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case description
        case htmlURL = "html_url"
    }
}
