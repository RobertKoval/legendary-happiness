//
//  TopRatedCodec.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

extension TopRatedDTO {
    func toMovies(favorites: Set<Int> = []) -> Movies {
        let movies = results.map { dto in
            Movie(id: dto.id,
                  title: dto.title,
                  rating: dto.voteAverage,
                  posterPath: dto.posterPath,
                  isFavorite: favorites.contains(dto.id))
        }

        return Movies(page: page,
                      totalPages: totalPages,
                      movies: movies,
                      averageRatingText: Self.makeAverageRatingText(from: movies))
    }

    private static func makeAverageRatingText(from movies: [Movie]) -> String? {
        guard !movies.isEmpty else { return nil }
        let totalRating = movies.reduce(0.0) { partialResult, movie in
            partialResult + movie.rating
        }
        let average = totalRating / Double(movies.count)
        return formatRating(average)
    }
}

extension DetailsDTO {
    func toMovieDetails(imageData: Data) -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            overview: overview,
            releaseDate: Self.formatReleaseDate(releaseDate),
            rating: formatRating(voteAverage),
            imageData: imageData
        )
    }

    private static func formatReleaseDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"

        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }

        return outputFormatter.string(from: date)
    }
}

// MARK: - Common
private func formatRating(_ rating: Double) -> String {
    String(format: "%.1f", rating)
}
