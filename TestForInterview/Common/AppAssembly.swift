//
//  AppAssembly.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

import UIKit
import SwiftUI

@MainActor
struct AppAssembly {
    let api: TMDBClient
    let localStorage: LocalStorage
    let placeholderGenerator: ImagePlaceholderGenerator

    init(api: TMDBClient = .live,
         localStorage: LocalStorage = .live,
         placeholderGenerator: ImagePlaceholderGenerator = .live) {
        self.api = api
        self.localStorage = localStorage
        self.placeholderGenerator = placeholderGenerator
    }

    // MARK: - Catalog
    func makeCatalogViewController() -> CatalogViewController {
        let viewModel = CatalogViewModel(api: api, localStorage: localStorage)
        let controller: CatalogViewController = CatalogViewController.instantiate()
        controller.viewModel = viewModel
        controller.dependencies = self
        return controller
    }

    // MARK: - Search
    func makeSearchViewController(onDismiss: (() -> Void)? = nil) -> SearchViewController {
        let viewModel = SearchViewModel(api: api, localStorage: localStorage)
        let controller = SearchViewController()
        controller.viewModel = viewModel
        controller.dependencies = self
        controller.onDismiss = onDismiss
        return controller
    }

    // MARK: - Movie Details
    func makeMovieDetailsViewController(movieId: Int,
                                        onBack: @escaping () -> Void,
                                        cachedDetailsDTO: DetailsDTO? = nil) -> UIViewController {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieTitle: "",
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
