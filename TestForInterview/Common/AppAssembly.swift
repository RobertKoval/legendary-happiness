//
//  AppAssembly.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

import SwiftUI
import UIKit

@MainActor
struct AppAssembly {
    private let api: TMDBClient
    private let localStorage: LocalStorage
    private let placeholderGenerator: ImagePlaceholderGenerator
    private let themeManager: ThemeManager

    init(environment: AppEnvironment) {
        self.api = environment.api
        self.localStorage = environment.localStorage
        self.placeholderGenerator = environment.placeholderGenerator
        self.themeManager = environment.themeManager
    }

    // MARK: - Catalog
    func makeCatalogViewController() -> CatalogViewController {
        let viewModel = CatalogViewModel(
            api: api, localStorage: localStorage, themeManager: themeManager)
        let controller: CatalogViewController = CatalogViewController.instantiate()
        controller.viewModel = viewModel
        controller.appAssembly = self

        return controller
    }

    // MARK: - Search
    func makeSearchViewController(onDismiss: (() -> Void)? = nil) -> SearchViewController {
        let viewModel = SearchViewModel(api: api, localStorage: localStorage)
        let controller = SearchViewController()
        controller.viewModel = viewModel
        controller.appAssembly = self
        controller.onDismiss = onDismiss
        return controller
    }

    // MARK: - Movie Details
    func makeMovieDetailsViewController(
        movieId: Int,
        movieTitle: String,
        onBack: @escaping () -> Void,
        cachedDetailsDTO: DetailsDTO? = nil
    ) -> UIViewController {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieTitle: movieTitle,
            api: api,
            localStorage: localStorage,
            placeholderGenerator: placeholderGenerator,
            cachedDetailsDTO: cachedDetailsDTO
        )
        let view = MovieDetailsView(viewModel: viewModel, onBack: onBack)
        return UIHostingController(rootView: view)
    }

    // MARK: - Favorites
    func makeFavoritesSheetViewController(onDismiss: (() -> Void)? = nil)
        -> FavoritesSheetViewController
    {
        let viewModel = FavoritesViewModel(api: api, localStorage: localStorage)
        let controller = FavoritesSheetViewController()
        controller.viewModel = viewModel
        controller.dependencies = self
        controller.onDismiss = onDismiss
        return controller
    }
}
