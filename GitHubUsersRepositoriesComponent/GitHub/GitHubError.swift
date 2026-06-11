//
//  GitHubError.swift
//  GitHubUsersRepositoriesComponent
//
//  Errors the GitHub layer can surface, each with a message suitable
//  for showing in the autocomplete error state.
//

import Foundation

enum GitHubError: LocalizedError {
    /// Search rate limit hit (HTTP 403 with a rate-limit header)
    case rateLimited
    /// A non-success HTTP status we don't handle specifically
    case httpStatus(Int)
    /// The response wasn't a valid HTTP response
    case invalidResponse
    /// The body couldn't be decoded into the expected model
    case decoding(Error)
    /// The request failed before we got a response (offline, timeout, …)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .rateLimited:
            return "GitHub's rate limit was reached. Please wait a moment and try again."
        case .httpStatus(let code):
            return "GitHub returned an unexpected response (status \(code))."
        case .invalidResponse:
            return "Received an invalid response from GitHub."
        case .decoding:
            return "Couldn't read GitHub's response."
        case .transport:
            return "Network error. Please check your connection and try again."
        }
    }
}
