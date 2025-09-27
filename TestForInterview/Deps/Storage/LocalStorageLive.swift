//
//  LocalStorageLive.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

private enum StorageKey: String {
    case favoriteMovieIds = "FavoriteMovieIds"
    case themePreference = "ThemePreference"
}

extension LocalStorage {
    static func live(defaults: UserDefaults = .standard) -> LocalStorage {
        return LocalStorage(
            getFavoriteMovieIds: {
                let favoriteIds =
                    defaults.array(forKey: StorageKey.favoriteMovieIds.rawValue) as? [Int] ?? []
                return Set(favoriteIds)
            },
            addFavoriteMovieId: { movieId in
                var favoriteIds =
                    defaults.array(forKey: StorageKey.favoriteMovieIds.rawValue) as? [Int] ?? []
                if !favoriteIds.contains(movieId) {
                    favoriteIds.append(movieId)
                    defaults.set(favoriteIds, forKey: StorageKey.favoriteMovieIds.rawValue)
                }
            },
            removeFavoriteMovieId: { movieId in
                var favoriteIds =
                    defaults.array(forKey: StorageKey.favoriteMovieIds.rawValue) as? [Int] ?? []
                favoriteIds.removeAll { $0 == movieId }
                defaults.set(favoriteIds, forKey: StorageKey.favoriteMovieIds.rawValue)
            },
            isFavorite: { movieId in
                let favoriteIds =
                    defaults.array(forKey: StorageKey.favoriteMovieIds.rawValue) as? [Int] ?? []
                return favoriteIds.contains(movieId)
            },
            getThemePreference: {
                defaults.string(forKey: StorageKey.themePreference.rawValue)
            },
            setThemePreference: { value in
                if let value {
                    defaults.set(value, forKey: StorageKey.themePreference.rawValue)
                } else {
                    defaults.removeObject(forKey: StorageKey.themePreference.rawValue)
                }
            }
        )
    }

    static let live = live()
}
