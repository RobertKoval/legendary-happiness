//
//  TMDBClient.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import Foundation

struct TMDBClient {
    let getMovieDetails: (Int) async throws -> DetailsDTO
    let getTopRatedMoviesAtPage: (Int) async throws -> TopRatedDTO
    let downloadImageAtPath: (String) async throws -> Data
}
