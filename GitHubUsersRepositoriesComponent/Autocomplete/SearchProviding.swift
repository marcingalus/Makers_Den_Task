//
//  SearchProviding.swift
//  GitHubUsersRepositoriesComponent
//
//  The data-source contract the autocomplete component depends on.
//  Any type that can turn a query string into displayable items can
//  drive the component: GitHub, a local cache, an in-memory stub, etc.
//

import Foundation

/// Provides search results for a query string
protocol SearchProviding {
    associatedtype Item: AutocompleteDisplayable

    /// Returns items matching `query`
    ///
    /// Conformers should support cooperative cancellation so that
    /// superseded searches stop work promptly.
    func search(_ query: String) async throws -> [Item]
}
