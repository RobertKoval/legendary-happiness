//
//  SearchViewModel.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var state: ViewState<Movies> = .idle
    @Published var searchText: String = ""

    private let api: TMDBClient
    private let localStorage: LocalStorage
    private var cancellables = Set<AnyCancellable>()
    private var activeTask: Task<Void, Never>?
    private var activeQuery: String?
    private var activePage: Int = 0

    init(api: TMDBClient, localStorage: LocalStorage) {
        self.api = api
        self.localStorage = localStorage
        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchMovies(query: query)
            }
            .store(in: &cancellables)
    }

    func searchMovies(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 3 else {
            cancelActiveTask()
            activeQuery = nil
            activePage = 0
            state = .idle
            return
        }

        runSearch(query: trimmedQuery, page: 1, showLoading: true)
    }

    func loadPage(_ page: Int) {
        guard let query = activeQuery, page >= 1 else {
            return
        }

        if case let .loaded(data) = state, data.page == page {
            return
        }

        runSearch(query: query, page: page, showLoading: true)
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
    private func runSearch(query: String, page: Int, showLoading: Bool) {
        cancelActiveTask()
        activeQuery = query
        activePage = page

        activeTask = Task { [weak self] in
            await self?.performSearch(query: query, page: page, showLoading: showLoading)
        }
    }

    private func cancelActiveTask() {
        activeTask?.cancel()
        activeTask = nil
    }

    private func performSearch(query: String, page: Int, showLoading: Bool) async {
        if showLoading {
            state = .loading
        }

        do {
            let favorites = localStorage.getFavoriteMovieIds()
            let searchResult = try await api.searchMovies(query, page)

            guard !Task.isCancelled else { return }
            guard activeQuery == query, activePage == page else { return }

            let movies = searchResult.toMovies(favorites: favorites)
            activePage = movies.page
            state = .loaded(movies)
        } catch {
            guard !Task.isCancelled else { return }
            guard activeQuery == query, activePage == page else { return }

            state = .failed(error.toEquatableError())
        }
    }

    deinit {
        activeTask?.cancel()
    }
}
