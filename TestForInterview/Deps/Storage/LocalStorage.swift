//
//  LocalStorage.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

struct LocalStorage {
    let getFavoriteMovieIds: () -> Set<Int>
    let addFavoriteMovieId: (Int) -> Void
    let removeFavoriteMovieId: (Int) -> Void
    let isFavorite: (Int) -> Bool
    let getThemePreference: () -> String?
    let setThemePreference: (String?) -> Void
}
