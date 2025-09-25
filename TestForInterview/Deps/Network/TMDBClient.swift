//
//  TMDBClient.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

struct TMDBClient {
    let getMovieDetails: (Int) async throws -> Void // TODO: 
    let getTopRatedMoviesAtPage: (Int) async throws -> TopRated
}
