//
//  MovieDetailsContentView.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import SwiftUI

struct MovieDetailsContentView: View {
    let movieDetails: MovieDetails
    let isFavorite: Bool
    
    let onFavoriteToggle: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(.searchGlass)
                    .aspectRatio(1/1.7, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                Text("Rating: \(movieDetails.ratingText)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(movieDetails.overview)
                    .font(.body)
                    .foregroundColor(.primary)

                Text(movieDetails.releaseDateText)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                favoriteButton
            }
        }
    }

    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            Text(isFavorite ? "Remove from favorites" : "Add to favorites")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 47)
        }
        .background(isFavorite ? Color.clear : Color(.favorite))
        .foregroundColor(isFavorite ? Color.newBlack : Color.text)
        .overlay(Capsule().stroke(Color.secondary, lineWidth: isFavorite ? 1 : 0))
        .clipShape(Capsule())
    }
}
