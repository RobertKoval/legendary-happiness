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

    func url(baseURL: String) -> URL? {
        let path: String
        let queryItems: [URLQueryItem]

        switch self {
        case .topRated(let page):
            path = "/movie/top_rated"
            queryItems = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .movieDetails(let id):
            path = "/movie/\(id)"
            queryItems = [
                URLQueryItem(name: "language", value: "en-US")
            ]
        }

        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

extension TMDBClient {
    static func live(apiKey: String = Helper.apiKey,
                     baseURL: String = "https://api.themoviedb.org/3",
                     session: URLSession = .shared) -> TMDBClient {
        TMDBClient(
            getMovieDetails: { movieId in
                // TODO: Implement movie details fetch
            },
            getTopRatedMoviesAtPage: { page in
                guard let url = TMDBEndpoint.topRated(page: page).url(baseURL: baseURL) else {
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
                return try JSONDecoder().decode(TopRated.self, from: data)
            }
        )
    }

    static let live = live()
}
