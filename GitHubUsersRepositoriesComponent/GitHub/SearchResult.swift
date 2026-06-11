//
//  SearchResult.swift
//  GitHubUsersRepositoriesComponent
//
//  Unified row model that flattens a GitHub user or repository into a
//  single type so both kinds can live in one combined, sorted list.
//

import Foundation

/// A single combined search result, either a user or a repository
struct SearchResult: AutocompleteDisplayable {
    enum Kind: Hashable {
        case user
        case repository
    }

    let id: String
    let kind: Kind
    /// Repository name or user login, used as the primary label and sort key
    let title: String
    /// Secondary label: repository full name or owner login
    let subtitle: String?
    let avatarURL: URL?
    let htmlURL: URL?

    var sortKey: String { title.lowercased() }
}

extension SearchResult {
    init(user: GitHubUser) {
        self.init(
            id: "user-\(user.id)",
            kind: .user,
            title: user.login,
            subtitle: nil,
            avatarURL: user.avatarURL,
            htmlURL: user.htmlURL
        )
    }

    init(repository: GitHubRepository) {
        self.init(
            id: "repo-\(repository.id)",
            kind: .repository,
            title: repository.name,
            subtitle: repository.owner.login,
            avatarURL: repository.owner.avatarURL,
            htmlURL: repository.htmlURL
        )
    }
}
