//
//  CatalogVM.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import Foundation

final class CatalogViewModel: ObservableObject {
    @Published var state: ViewState<Movies> = .idle

    private let api: TMDBClient
    private let localStorage: LocalStorage

    init(api: TMDBClient, localStorage: LocalStorage) {
        self.api = api
        self.localStorage = localStorage
    }

    func fetchMovies() {
        Task { @MainActor in
            switch state {
            case .idle, .failed:
                state = .loading
            case .loaded, .loading:
                break
            }

            do {
                let topRatedResponse = try await api.getTopRatedMoviesAtPage(1)
                let favoriteIds = localStorage.getFavoriteMovieIds()
                let newMovies = topRatedResponse.toMovies(favorites: favoriteIds)
                state = .loaded(newMovies)
            } catch {
                state = .failed(error.toEquatableError())
            }
        }
    }

    func refreshMovies() {
        fetchMovies()
    }

    func posterURLForMovieAt(index: Int) -> URL? {
        guard case let .loaded(data) = state else {
            return nil
        }
        return api.imageUrlFromPath(data.movies[index].posterPath)
    }
}
