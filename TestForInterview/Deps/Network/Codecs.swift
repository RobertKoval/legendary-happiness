//
//  TopRatedCodec.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

extension TopRatedDTO {
    func toMovies(favorites: Set<Int> = []) -> Movies {
        Movies(page: page,
               totalPages: totalPages,
               movies: results.map { dto in
            Movie(id: dto.id,
                  title: dto.title,
                  rating: dto.voteAverage,
                  posterURL: URL(string: "https://image.tmdb.org/t/p/w500\(dto.posterPath)")!,
                  isFavorite: favorites.contains(dto.id))
        })
    }
}

extension DetailsDTO {
    func toMovieDetails(imageData: Data) -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            overview: overview,
            releaseDate: formatReleaseDate(releaseDate),
            rating: formatRating(voteAverage),
            imageData: imageData
        )
    }

    private func formatReleaseDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"

        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }

        return outputFormatter.string(from: date)
    }

    private func formatRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }
}
