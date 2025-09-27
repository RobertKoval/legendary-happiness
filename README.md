# Movie Catalog

## Overview
- iOS 13+ sample app that showcases TMDB “Top Rated” movies with search, favorites, and a SwiftUI detail screen.
- Built with MVVM, UIKit (diffable collection views) for lists, and SwiftUI hosted through `UIHostingController` for movie details.
- Includes manual theme override (System / Light / Dark), pull-to-refresh, and a custom favorites sheet animation.

## Requirements
- macOS with Xcode 16 or newer (tested on Xcode 16.2).
- iOS Simulator runtime (iPhone 11 on iOS 15.5).
- TMDB v3 read access bearer token.

## Setup
1. Clone the repository
   ```bash
   git clone <repo-url> TestForInterview
   cd TestForInterview
   ```
2. Supply your TMDB token by copying the template and inserting the value:
   ```bash
   export TMDB_API_KEY="<your_tmdb_token>"
   cp TestForInterview/Helper.swift.template TestForInterview/Helper.swift
   /usr/bin/sed -i '' "s/<#TMDB Token#>/${TMDB_API_KEY}/" TestForInterview/Helper.swift
   ```
   (Adjust the `sed` command for your shell, or edit the generated file manually.)
3. Open the project
   ```bash
   xed .
   ```

## Build
- **Xcode**: select the `TestForInterview` scheme and run on an iPhone 11 simulator (iOS 15.5).
- **Command line** (build):

```bash
xcodebuild -scheme TestForInterview \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=iPhone 11,OS=15.5" build
```

## Feature Highlights
- **Catalog**: Two-column grid, SDWebImage poster loading, average rating banner, pull-to-refresh, context menu for favorites, double-buffer pagination.
- **Search**: Debounced (500 ms) queries after 3+ characters, pagination footer, empty-state messaging, shared layout helper.
- **Favorites**: Custom modal sheet with spring animation, diffable datasource, empty-state handling, quick removal and details navigation.
- **Movie Details**: SwiftUI screen with poster, overview, release date, rating, and favorites button; reuses cached DTO when available.
- **Theming**: Action-sheet picker (System / Light / Dark) persisted through `ThemeManager` + `LocalStorage` and applied at the window level.

## Architecture
- MVVM per feature module; `ViewState<T>` models async state.
- `AppAssembly` composes controllers using shared dependencies (`TMDBClient`, `LocalStorage`, `ThemeManager`, placeholder generator).
- Shared UI helpers (collection layout, loader, empty state) live under `Common/` and `Components/`.
- SDWebImage is integrated via Swift Package Manager for remote images.

## Project Structure
```
TestForInterview/
  Common/            # DI assembly, theme manager, layout + state helpers
  Components/        # LoaderView, EmptyStateView
  Deps/              # Network & storage abstractions (TMDB clients, DTOs)
  Features/          # Catalog / Search / Favorites / MovieDetails modules
  Assets.xcassets/   # Colors, icons, placeholders
  Helper.swift.template  # Copy to Helper.swift and insert TMDB token (ignored in git)
```

## Notes
- If you see a build failure referencing `Helper.apiKey`, confirm the token was inserted and clean/rebuild.
- Theme selection persists across launches; reset simulator defaults if you need to return to “System”.
