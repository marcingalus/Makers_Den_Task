//
//  GitHubConfiguration.swift
//  GitHubUsersRepositoriesComponent
//
//  Single place for the values that drive GitHub requests, so nothing
//  is hardcoded across the networking layer. Inject a custom instance
//  to point at a different host, supply a token, or change page size.
//

import Foundation

struct GitHubConfiguration {
    /// API root, e.g. https://api.github.com
    var baseURL: URL
    /// Personal access token; nil means unauthenticated requests
    var token: String?
    /// Value sent in the X-GitHub-Api-Version header
    var apiVersion: String
    /// Value sent in the User-Agent header (GitHub requires one)
    var userAgent: String
    /// Items requested per endpoint; the brief caps this at 50
    var resultsPerPage: Int

    init(
        baseURL: URL = Default.baseURL,
        token: String? = GitHubConfiguration.environmentToken,
        apiVersion: String = Default.apiVersion,
        userAgent: String = Default.userAgent,
        resultsPerPage: Int = Default.resultsPerPage
    ) {
        self.baseURL = baseURL
        self.token = token
        self.apiVersion = apiVersion
        self.userAgent = userAgent
        self.resultsPerPage = resultsPerPage
    }

    /// Default values
    enum Default {
        static let baseURL = URL(string: "https://api.github.com")!
        static let apiVersion = "2022-11-28"
        static let userAgent = "GitHubUsersRepositoriesComponent"
        /// The brief caps results at 50 per request
        static let resultsPerPage = 50
        /// Environment variable that supplies an optional token
        static let tokenEnvironmentKey = "GITHUB_TOKEN"
    }

    /// Token read from the GITHUB_TOKEN environment variable, if set
    static var environmentToken: String? {
        let token = ProcessInfo.processInfo.environment[Default.tokenEnvironmentKey]
        return token?.isEmpty == false ? token : nil
    }
}
