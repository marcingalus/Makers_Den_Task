//
//  GitHubAPIClient.swift
//  GitHubUsersRepositoriesComponent
//
//  Thin URLSession wrapper that performs a GitHub request and decodes
//  the response. Adds the required headers, attaches a bearer token when
//  one is configured, and maps failures onto GitHubError. The session is
//  injectable so tests can stub the network.
//

import Foundation

struct GitHubAPIClient {
    /// Media type GitHub expects for v3 JSON responses
    private static let acceptHeader = "application/vnd.github+json"

    private let session: URLSession
    private let configuration: GitHubConfiguration

    init(
        session: URLSession = .shared,
        configuration: GitHubConfiguration = GitHubConfiguration()
    ) {
        self.session = session
        self.configuration = configuration
    }

    /// Performs `endpoint` and decodes the body into `Response`
    func get<Response: Decodable>(_ endpoint: GitHubEndpoint) async throws -> Response {
        guard let url = endpoint.url(baseURL: configuration.baseURL) else {
            throw GitHubError.invalidResponse
        }

        let request = makeRequest(url: url)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            // Surfaced as cancellation so the view model can ignore it
            throw CancellationError()
        } catch {
            throw GitHubError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw GitHubError.decoding(error)
            }
        case 403, 429:
            throw isRateLimited(http) ? GitHubError.rateLimited : GitHubError.httpStatus(http.statusCode)
        default:
            throw GitHubError.httpStatus(http.statusCode)
        }
    }

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(Self.acceptHeader, forHTTPHeaderField: "Accept")
        request.setValue(configuration.apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue(configuration.userAgent, forHTTPHeaderField: "User-Agent")
        if let token = configuration.token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func isRateLimited(_ response: HTTPURLResponse) -> Bool {
        response.value(forHTTPHeaderField: "X-RateLimit-Remaining") == "0"
    }
}
