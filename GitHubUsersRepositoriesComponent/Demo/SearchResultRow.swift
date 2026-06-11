//
//  SearchResultRow.swift
//  GitHubUsersRepositoriesComponent
//
//  Row UI for a single GitHub search result. This is the host's
//  responsibility, kept out of the reusable component so the component
//  stays free of GitHub-specific presentation.
//

import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: Constants.rowSpacing) {
            avatar
            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Text(result.title)
                if let subtitle = result.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: Constants.spacerMinLength)
            kindBadge
        }
        .padding(.vertical, Constants.rowVerticalPadding)
    }

    private var avatar: some View {
        AsyncImage(url: result.avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: fallbackSymbol)
                .resizable()
                .scaledToFit()
                .padding(Constants.avatarPadding)
                .foregroundStyle(.tertiary)
        }
        .frame(width: Constants.avatarSize, height: Constants.avatarSize)
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: Constants.avatarCornerRadius))
    }

    private var kindBadge: some View {
        Text(result.kind == .user ? "User" : "Repo")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, Constants.badgeHorizontalPadding)
            .padding(.vertical, Constants.badgeVerticalPadding)
            .background(badgeColor.opacity(Constants.badgeBackgroundOpacity), in: Capsule())
            .foregroundStyle(badgeColor)
    }

    private var fallbackSymbol: String {
        result.kind == .user ? "person.fill" : "folder.fill"
    }

    private var badgeColor: Color {
        result.kind == .user ? .blue : .purple
    }
}

private extension SearchResultRow {
    enum Constants {
        static let rowSpacing: CGFloat = 12
        static let textSpacing: CGFloat = 2
        static let spacerMinLength: CGFloat = 8
        static let rowVerticalPadding: CGFloat = 2
        static let avatarSize: CGFloat = 40
        static let avatarCornerRadius: CGFloat = 8
        static let avatarPadding: CGFloat = 8
        static let badgeHorizontalPadding: CGFloat = 8
        static let badgeVerticalPadding: CGFloat = 3
        static let badgeBackgroundOpacity: Double = 0.15
    }
}

#Preview {
    List {
        SearchResultRow(result: SampleSearchProvider.sample[0])
        SearchResultRow(result: SampleSearchProvider.sample[1])
    }
}
