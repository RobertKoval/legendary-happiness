//
//  TopRatedCodec.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

extension TopRated {
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
