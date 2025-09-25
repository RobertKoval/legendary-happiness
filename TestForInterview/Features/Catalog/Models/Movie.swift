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

    var count: Int {
        movies.count
    }
}

struct Movie: Equatable {
    let id: Int
    let title: String
    let rating: Double
    let posterPath: String
    let isFavorite: Bool

    init(id: Int,
         title: String,
         rating: Double,
         posterPath: String,
         isFavorite: Bool) {
        self.id = id
        self.title = title
        self.rating = rating
        self.posterPath = posterPath
        self.isFavorite = isFavorite
    }
}
