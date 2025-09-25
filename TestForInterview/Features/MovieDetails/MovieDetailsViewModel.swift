//
//  MovieDetailViewModel.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import Foundation

final class MovieDetailsViewModel: ObservableObject {
    @Published var state: ViewState<MovieDetails> = .idle
    @Published var isFavorite: Bool = false

    private let movieId: Int
    let title: String
    private let api: TMDBClient
    private let localStorage: LocalStorage

    init(movieId: Int, movieTitle: String, api: TMDBClient, localStorage: LocalStorage) {
        self.movieId = movieId
        self.title = movieTitle
        self.api = api
        self.localStorage = localStorage
        self.isFavorite = localStorage.isFavorite(movieId)
    }

    // MARK: - Actions
    func loadMovieDetails() {
        Task { @MainActor in
            state = .loading

            do {
                let detailsDTO = try await api.getMovieDetails(movieId)
                let imageData = try await api.downloadImageAtPath(detailsDTO.posterPath)
                let movieDetails = detailsDTO.toMovieDetails(imageData: imageData)
                state = .loaded(movieDetails)
            } catch {
                state = .failed(error.toEquatableError())
            }
        }
    }

    func onFavorite() {
        if isFavorite {
            localStorage.removeFavoriteMovieId(movieId)
        } else {
            localStorage.addFavoriteMovieId(movieId)
        }
        isFavorite.toggle()
    }
}
