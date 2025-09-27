//
//  Movie.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

struct Movies: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
    let averageRatingText: String?
    let totalResults: Int

    var count: Int {
        movies.count
    }
}

struct Movie: Hashable {
    let id: Int
    let title: String
    let rating: Double
    let posterPath: String?
    let isFavorite: Bool

    init(id: Int,
         title: String,
         rating: Double,
         posterPath: String?,
         isFavorite: Bool) {
        self.id = id
        self.title = title
        self.rating = rating
        self.posterPath = posterPath
        self.isFavorite = isFavorite
    }
}

extension Movie {
    func posterURL(from api: TMDBClient) -> URL? {
        guard let path = posterPath else { return nil }
        return api.imageUrlFromPath(path)
    }
}
