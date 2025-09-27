//
//  MovieDetails.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

struct MovieDetails: Equatable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String  // Formatted
    let rating: String
    let imageData: Data
}
