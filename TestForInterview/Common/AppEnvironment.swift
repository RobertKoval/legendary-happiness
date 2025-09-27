//
//  AppEnvironment.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

@MainActor
struct AppEnvironment {
    let api: TMDBClient
    let localStorage: LocalStorage
    let placeholderGenerator: ImagePlaceholderGenerator
    let themeManager: ThemeManager

    static func live() -> AppEnvironment {
        let storage = LocalStorage.live()
        return AppEnvironment(
            api: .live,
            localStorage: storage,
            placeholderGenerator: .live,
            themeManager: ThemeManager(localStorage: storage)
        )
    }
}
