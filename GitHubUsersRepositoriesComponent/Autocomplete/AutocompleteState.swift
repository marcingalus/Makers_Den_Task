//
//  AutocompleteState.swift
//  GitHubUsersRepositoriesComponent
//
//  The single source of truth the view renders from. Every visible
//  state the brief calls out (loading, empty, error) is a case here.
//

import Foundation

/// The current state of an autocomplete search
enum AutocompleteState<Item: AutocompleteDisplayable>: Equatable {
    /// Nothing to show: query is empty or below the minimum length
    case idle
    /// A search is in flight
    case loading
    /// Search returned at least one item
    case results([Item])
    /// Search completed but matched nothing
    case empty
    /// Search failed; `message` is user-facing
    case error(String)
}
