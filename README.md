# GitHub Users & Repositories Autocomplete

A small SwiftUI autocomplete that searches GitHub for users and repositories at the same time, combines them into one alphabetically sorted list, and copes with slow networks and fast typing. No third-party libraries.

## Running it

Open `GitHubUsersRepositoriesComponent.xcodeproj`, pick an iOS simulator, run, and type at least 3 characters (`swift` for example).

GitHub's search API allows roughly 10 requests/min unauthenticated, so if you hammer it you'll see the rate-limit error state. To avoid that, set a `GITHUB_TOKEN` environment variable on the run scheme (Edit Scheme → Run → Arguments). When it's present the client sends it as a bearer token; otherwise requests go out unauthenticated.

## How it works

The autocomplete itself doesn't know anything about GitHub. It's generic over a `SearchProviding` protocol whose results are `AutocompleteDisplayable`, so the same view and view model can be pointed at any source. GitHub is just one implementation of that protocol.

- `Autocomplete/` — the reusable part: the two protocols, the state enum, the `@Observable` view model, and the view.
- `GitHub/` — the GitHub data source: models, the URLSession client, configuration, and the search service that fetches users and repos concurrently and merges them.
- `Demo/` — the example screen that wires GitHub into the component and supplies the row UI.

Dropping the component into another screen looks like this:

```swift
let viewModel = AutocompleteViewModel(provider: GitHubSearchService())
AutocompleteView(viewModel: viewModel) { result in
    SearchResultRow(result: result)
}
```

A couple of decisions worth calling out:

- The view model owns the debounce. Each keystroke cancels the previous search and the new one waits ~300ms before going to the network, so a burst of typing only ever results in one request. Cancellation flows through to `URLSession`.
- Sorting and merging happen in `GitHubSearchService`, since that's the thing holding two separate lists. If either request fails the whole search fails — that seemed more honest than showing half the results.
- The view model is owned by the host (`@State`) and borrowed by the view (`@Bindable`), so the component doesn't fight the host over lifecycle.

## Tests

The view model tests use a mock provider to check the 3-character gate, the loading/empty/error states, and — the interesting one — that rapid input collapses to a single search for the last query. The service tests stub `URLSession` with a `URLProtocol` to check decoding, the merged alphabetical order across both kinds, the 50-per-request limit, and rate-limit handling.
