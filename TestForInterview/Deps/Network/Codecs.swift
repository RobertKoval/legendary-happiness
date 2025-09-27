//
//  TopRatedCodec.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

private enum TopRatedMappingConstants {
    static let maxPageCount: Int = 500
}

extension TopRatedDTO {
    var limitedTotalPages: Int {
        min(totalPages, TopRatedMappingConstants.maxPageCount)
    }

    func toMovies(favorites: Set<Int> = []) -> Movies {
        let movies = results.map { dto in
            Movie(
                id: dto.id,
                title: dto.title,
                rating: dto.voteAverage,
                posterPath: dto.posterPath,
                isFavorite: favorites.contains(dto.id))
        }

        return Movies(
            page: page,
            totalPages: limitedTotalPages,
            movies: movies,
            averageRatingText: movies.makeAverageRatingText(),
            totalResults: totalResults)
    }
}

extension Array where Element == Movie {
    func makeAverageRatingText() -> String? {
        guard !isEmpty else { return nil }
        let totalRating = reduce(0.0) { partial, movie in
            partial + movie.rating
        }
        let average = totalRating / Double(count)
        return formatRating(average)
    }
}

extension SearchDTO {
    var limitedTotalPages: Int {
        min(totalPages, TopRatedMappingConstants.maxPageCount)
    }

    func toMovies(favorites: Set<Int> = []) -> Movies {
        let movies = results.map { dto in
            Movie(
                id: dto.id,
                title: dto.title,
                rating: dto.voteAverage,
                posterPath: dto.posterPath,
                isFavorite: favorites.contains(dto.id))
        }

        return Movies(
            page: page,
            totalPages: limitedTotalPages,
            movies: movies,
            averageRatingText: nil,
            totalResults: totalResults)
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

    func toMovie(isFavorite: Bool) -> Movie {
        Movie(
            id: id,
            title: title,
            rating: voteAverage,
            posterPath: posterPath,
            isFavorite: isFavorite
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
