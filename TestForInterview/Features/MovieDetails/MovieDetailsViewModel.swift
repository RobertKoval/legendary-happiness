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
    private let placeholderGenerator: ImagePlaceholderGenerator
    private let cachedDetailsDTO: DetailsDTO?

    init(movieId: Int,
         movieTitle: String,
         api: TMDBClient,
         localStorage: LocalStorage,
         placeholderGenerator: ImagePlaceholderGenerator,
         cachedDetailsDTO: DetailsDTO? = nil) {
        self.movieId = movieId
        self.title = movieTitle
        self.api = api
        self.localStorage = localStorage
        self.placeholderGenerator = placeholderGenerator
        self.cachedDetailsDTO = cachedDetailsDTO
        self.isFavorite = localStorage.isFavorite(movieId)
    }

    // MARK: - Actions
    func loadMovieDetails() {
        Task { @MainActor in
            state = .loading

            do {
                let detailsDTO: DetailsDTO

                if let cached = cachedDetailsDTO {
                    detailsDTO = cached
                } else {
                    detailsDTO = try await api.getMovieDetails(movieId)
                }

                let imageData: Data
                if let path = detailsDTO.posterPath {
                    imageData = try await api.downloadImageAtPath(path)
                } else {
                    imageData = placeholderGenerator.generatePosterPlaceholder()
                }

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
