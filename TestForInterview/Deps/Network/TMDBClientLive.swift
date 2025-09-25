//
//  TMDBClientLive.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

private enum TMDBEndpoint {
    case topRated(page: Int)
    case movieDetails(id: Int)
    case image(path: String)
    
    func url(apiBaseURL: String, imageBaseURL: String) -> URL? {
        switch self {
        case .topRated(let page):
            let path = "/movie/top_rated"
            let queryItems = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ]
            var components = URLComponents(string: apiBaseURL + path)
            components?.queryItems = queryItems
            return components?.url
            
        case .movieDetails(let id):
            let path = "/movie/\(id)"
            let queryItems = [
                URLQueryItem(name: "language", value: "en-US")
            ]
            var components = URLComponents(string: apiBaseURL + path)
            components?.queryItems = queryItems
            return components?.url
            
        case .image(let imagePath):
            return URL(string: "\(imageBaseURL)\(imagePath)")
        }
    }
}

extension TMDBClient {
    // TODO: Move request creation into separate helper function with generic decode type.
    
    static func live(apiKey: String = Helper.apiKey,
                     apiBaseURL: String = "https://api.themoviedb.org/3",
                     imageBaseURL: String = "https://image.tmdb.org/t/p/w500",
                     session: URLSession = .shared) -> TMDBClient {
        TMDBClient(
            getMovieDetails: { movieId in
                guard let url = TMDBEndpoint.movieDetails(id: movieId).url(apiBaseURL: apiBaseURL, imageBaseURL: imageBaseURL) else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                request.allHTTPHeaderFields = [
                    "accept": "application/json",
                    "Authorization": "Bearer \(apiKey)"
                ]
                
                let (data, _) = try await URLSession.shared.data(for: request)
                return try JSONDecoder().decode(DetailsDTO.self, from: data)
            },
            getTopRatedMoviesAtPage: { page in
                guard let url = TMDBEndpoint.topRated(page: page).url(apiBaseURL: apiBaseURL, imageBaseURL: imageBaseURL) else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                request.allHTTPHeaderFields = [
                    "accept": "application/json",
                    "Authorization": "Bearer \(apiKey)"
                ]
                
                let (data, _) = try await URLSession.shared.data(for: request)
                return try JSONDecoder().decode(TopRatedDTO.self, from: data)
            },
            downloadImageAtPath: { imagePath in
                guard let url = TMDBEndpoint.image(path: imagePath).url(apiBaseURL: apiBaseURL, imageBaseURL: imageBaseURL) else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
        )
    }
    
    static let live = live()
}
