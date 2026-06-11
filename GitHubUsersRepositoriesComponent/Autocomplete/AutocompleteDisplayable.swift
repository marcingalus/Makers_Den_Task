//
//  AutocompleteDisplayable.swift
//  GitHubUsersRepositoriesComponent
//
//  Contract an item must satisfy to be shown and ordered by the
//  reusable autocomplete component. Domain-agnostic: the component
//  knows nothing about GitHub, only about this protocol.
//

import Foundation

/// An item the autocomplete component can identify and sort
protocol AutocompleteDisplayable: Identifiable, Hashable {
    /// Case-insensitive key used to order results alphabetically
    var sortKey: String { get }
}
