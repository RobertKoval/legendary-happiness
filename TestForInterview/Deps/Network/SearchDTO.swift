//
//  SearchDTO.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import Foundation

// MARK: - Search
struct SearchDTO: Codable {
    let page: Int
    let results: [Result]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}