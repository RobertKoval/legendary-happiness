//
//  ThemeManager.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

import Combine
import UIKit

// MARK: - Theme Model

enum Theme: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension Theme: Identifiable {
    var id: String { rawValue }
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {

    private let localStorage: LocalStorage

    @Published private(set) var theme: Theme

    var interfaceStyle: UIUserInterfaceStyle {
        theme.interfaceStyle
    }

    var themePublisher: AnyPublisher<Theme, Never> {
        $theme.removeDuplicates().eraseToAnyPublisher()
    }

    init(localStorage: LocalStorage = .live()) {
        self.localStorage = localStorage
        if let storedValue = localStorage.getThemePreference(),
            let storedTheme = Theme(rawValue: storedValue)
        {
            theme = storedTheme
        } else {
            theme = .system
        }
    }

    func setTheme(_ newTheme: Theme) {
        guard theme != newTheme else { return }
        theme = newTheme
        localStorage.setThemePreference(newTheme.rawValue)
    }
}

extension ThemeManager {
    var currentTheme: Theme { theme }
}
