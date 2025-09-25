//
//  UIConstants.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

enum UIConstants {
    // MARK: - Layout
    enum Layout {
        static let catalogColumns = 2
        static let catalogOuterHorizontalSpacing: CGFloat = 16.5
        static let catalogHeaderHeight: CGFloat = 35
        static let catalogHeaderTopOffset: CGFloat = 24
        static let catalogNavBarOffset: CGFloat = 33

        static let movieDetailsPosterExtraHorizontalPadding: CGFloat = 46.5
        static let favoriteButtonMinHeight: CGFloat = 47
    }

    // MARK: - Aspect Ratios
    enum AspectRatio {
        static let catalogPosterHeightMultiplier: CGFloat = 1.667
        static let detailsPosterAspectRatio: CGFloat = 0.667
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let favoriteIcon: CGFloat = 20
        static let loaderSize: CGFloat = 80
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let poster: CGFloat = 15
    }
}
