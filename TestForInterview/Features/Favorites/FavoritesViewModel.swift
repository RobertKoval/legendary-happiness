//
//  FavoritesViewModel.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var state: ViewState<Movies> = .idle

    private let api: TMDBClient
    private let localStorage: LocalStorage
    private var cancellables = Set<AnyCancellable>()
    private var cachedDetailsDTO: [Int: DetailsDTO] = [:]

    init(api: TMDBClient, localStorage: LocalStorage) {
        self.api = api
        self.localStorage = localStorage
    }

    func loadFavorites() {
        let favoriteIds = localStorage.getFavoriteMovieIds()

        guard !favoriteIds.isEmpty else {
            let emptyMovies = Movies(
                page: 1,
                totalPages: 1,
                movies: [],
                averageRatingText: nil,
                totalResults: 0
            )
            state = .loaded(emptyMovies)
            return
        }

        Task { @MainActor in
            state = .loading

            do {
                let detailsDTOs = try await api.getMovieDetailsList(Array(favoriteIds))

                // Cache the DetailsDTO data by movie ID
                cachedDetailsDTO.removeAll()
                for dto in detailsDTOs {
                    cachedDetailsDTO[dto.id] = dto
                }

                let movies = detailsDTOs.map { $0.toMovie(isFavorite: true) }
                let sortedMovies = movies.sorted { $0.rating > $1.rating }

                let result = Movies(
                    page: 1,
                    totalPages: 1,
                    movies: sortedMovies,
                    averageRatingText: movies.makeAverageRatingText(),
                    totalResults: sortedMovies.count
                )

                state = .loaded(result)
            } catch {
                state = .failed(error.toEquatableError())
            }
        }
    }

    func removeFavorite(movieId: Int) {
        localStorage.removeFavoriteMovieId(movieId)
        cachedDetailsDTO.removeValue(forKey: movieId)

        guard case let .loaded(currentData) = state else { return }

        let updatedMovies = currentData.movies.filter { $0.id != movieId }
        let updatedData = Movies(
            page: currentData.page,
            totalPages: currentData.totalPages,
            movies: updatedMovies,
            averageRatingText: updatedMovies.makeAverageRatingText(),
            totalResults: updatedMovies.count
        )

        state = .loaded(updatedData)
    }

    func posterURL(for movie: Movie) -> URL? {
        return movie.posterURL(from: api)
    }

    func getCachedDetailsDTO(for movieId: Int) -> DetailsDTO? {
        return cachedDetailsDTO[movieId]
    }
}
