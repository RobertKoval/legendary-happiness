//
//  CatalogVM.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published var state: ViewState<Movies> = .idle
    
    private let api: TMDBClient
    private let localStorage: LocalStorage
    
    private var cachedNextPage: Movies? // Pre-loaded next page
    
    init(api: TMDBClient, localStorage: LocalStorage) {
        self.api = api
        self.localStorage = localStorage
    }
    
    func fetchMovies() {
        loadPage(1)
    }
    
    func refreshMovies() {
        guard case let .loaded(data) = state else {
            return
        }
        loadPage(data.page)
    }
    
    func posterURLForMovieAt(index: Int) -> URL? {
        guard case let .loaded(data) = state else {
            return nil
        }
        return posterURL(for: data.movies[index])
    }

    func posterURL(for movie: Movie) -> URL? {
        guard let path = movie.posterPath else {
            return nil
        }
        return api.imageUrlFromPath(path)
    }
    
    var averageRatingText: String? {
        guard case let .loaded(data) = state else {
            return nil
        }
        return data.averageRatingText
    }
    
    func loadPage(_ page: Int) {
        switch state {
        case .idle, .failed, .loaded:
            break
        case .loading:
            return
        }
        
        Task { @MainActor in
            if let cachedPage = getCachedPage(for: page) {
                state = .loaded(cachedPage)
                loadNextPageForCache(page + 1)
                return
            }
            
            state = .loading
            
            do {
                let favorites = localStorage.getFavoriteMovieIds()
                let (currentPage, nextPageCache) = try await loadPageWithCache(page, favorites: favorites)
                
                state = .loaded(currentPage)
                cachedNextPage = nextPageCache
            } catch {
                state = .failed(error.toEquatableError())
            }
        }
    }

    func refreshFavorites() {
        guard case let .loaded(data) = state else {
            return
        }

        let favorites = localStorage.getFavoriteMovieIds()
        let updatedMovies = data.movies.map { movie in
            Movie(id: movie.id,
                  title: movie.title,
                  rating: movie.rating,
                  posterPath: movie.posterPath,
                  isFavorite: favorites.contains(movie.id))
        }

        let updatedState = Movies(
            page: data.page,
            totalPages: data.totalPages,
            movies: updatedMovies,
            averageRatingText: data.averageRatingText,
            totalResults: data.totalResults
        )

        state = .loaded(updatedState)
    }

    // MARK: - Helper Functions
    private func getCachedPage(for page: Int) -> Movies? {
        guard let cachedPage = cachedNextPage, cachedPage.page == page else {
            return nil
        }
        cachedNextPage = nil
        return cachedPage
    }
    
    private func loadNextPageForCache(_ nextPage: Int) {
        guard case let .loaded(currentState) = state,
              nextPage <= currentState.totalPages,
              cachedNextPage == nil else {
            return
        }
        
        Task {
            do {
                let nextPageResponse = try await api.getTopRatedMoviesAtPage(nextPage)
                let favorites = localStorage.getFavoriteMovieIds()
                let nextPageMovies = nextPageResponse.toMovies(favorites: favorites)
                
                await MainActor.run {
                    guard cachedNextPage == nil else { return }
                    cachedNextPage = nextPageMovies
                }
            } catch {
                // Do nothing.
            }
        }
    }
    
    private func loadPageWithCache(_ page: Int,
                                   favorites: Set<Int>) async throws -> (Movies, Movies?) {
        async let currentTask = api.getTopRatedMoviesAtPage(page)
        async let nextTask = api.getTopRatedMoviesAtPage(page + 1)
        
        let current = try await currentTask
        let next = await (try? nextTask)
        
        let currentMovies = current.toMovies(favorites: favorites)
        let nextMovies = next?.toMovies(favorites: favorites)
        
        return (currentMovies, nextMovies)
    }
}
