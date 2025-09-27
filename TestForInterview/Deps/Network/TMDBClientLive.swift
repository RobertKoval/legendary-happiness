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
    case search(query: String, page: Int)
    case image(path: String)

    func url(baseURL: String) -> URL? {
        switch self {
        case .topRated(let page):
            let path = "/movie/top_rated"
            let queryItems = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page)),
            ]
            var components = URLComponents(string: baseURL + path)
            components?.queryItems = queryItems
            return components?.url

        case .movieDetails(let id):
            let path = "/movie/\(id)"
            let queryItems = [
                URLQueryItem(name: "language", value: "en-US")
            ]
            var components = URLComponents(string: baseURL + path)
            components?.queryItems = queryItems
            return components?.url

        case .search(let query, let page):
            let path = "/search/movie"
            let queryItems = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
            ]
            var components = URLComponents(string: baseURL + path)
            components?.queryItems = queryItems
            return components?.url

        case .image(let imagePath):
            return URL(string: "\(baseURL)\(imagePath)")
        }
    }
}

extension TMDBClient {
    // TODO: Move request creation into separate helper function with generic decode type.

    static func live(
        apiKey: String = Helper.apiKey,
        apiBaseURL: String = "https://api.themoviedb.org/3",
        imageBaseURL: String = "https://image.tmdb.org/t/p/w500",
        session: URLSession = .shared
    ) -> TMDBClient {
        TMDBClient(
            getMovieDetails: { movieId in
                guard let url = TMDBEndpoint.movieDetails(id: movieId).url(baseURL: apiBaseURL)
                else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                request.allHTTPHeaderFields = [
                    "accept": "application/json",
                    "Authorization": "Bearer \(apiKey)",
                ]

                let (data, _) = try await URLSession.shared.data(for: request)
                return try JSONDecoder().decode(DetailsDTO.self, from: data)
            },
            getMovieDetailsList: { movieIds in
                return try await withThrowingTaskGroup(of: DetailsDTO?.self) { group in
                    for id in movieIds {
                        group.addTask {
                            guard
                                let url = TMDBEndpoint.movieDetails(id: id).url(baseURL: apiBaseURL)
                            else {
                                throw URLError(.badURL)
                            }
                            var request = URLRequest(url: url)
                            request.httpMethod = "GET"
                            request.timeoutInterval = 10
                            request.allHTTPHeaderFields = [
                                "accept": "application/json",
                                "Authorization": "Bearer \(apiKey)",
                            ]

                            let (data, _) = try await URLSession.shared.data(for: request)
                            return try JSONDecoder().decode(DetailsDTO.self, from: data)
                        }
                    }

                    var results: [DetailsDTO] = []
                    for try await result in group {
                        if let result = result {
                            results.append(result)
                        }
                    }
                    return results
                }
            },
            getTopRatedMoviesAtPage: { page in
                guard let url = TMDBEndpoint.topRated(page: page).url(baseURL: apiBaseURL) else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                request.allHTTPHeaderFields = [
                    "accept": "application/json",
                    "Authorization": "Bearer \(apiKey)",
                ]

                let (data, _) = try await URLSession.shared.data(for: request)
                return try JSONDecoder().decode(TopRatedDTO.self, from: data)
            },
            searchMovies: { query, page in
                guard
                    let url = TMDBEndpoint.search(query: query, page: page).url(baseURL: apiBaseURL)
                else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10
                request.allHTTPHeaderFields = [
                    "accept": "application/json",
                    "Authorization": "Bearer \(apiKey)",
                ]

                let (data, _) = try await URLSession.shared.data(for: request)
                return try JSONDecoder().decode(SearchDTO.self, from: data)
            },
            downloadImageAtPath: { imagePath in
                guard let url = TMDBEndpoint.image(path: imagePath).url(baseURL: imageBaseURL)
                else {
                    throw URLError(.badURL)
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.timeoutInterval = 10

                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            },
            imageUrlFromPath: { path in
                return TMDBEndpoint.image(path: path).url(baseURL: imageBaseURL)
            }
        )
    }

    static let live = live()
}
