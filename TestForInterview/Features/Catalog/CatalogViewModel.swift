//
//  CatalogVM.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

final class CatalogViewModel {
    private let api: TMDBClient

    init(api: TMDBClient) {
        self.api = api
    }
}
