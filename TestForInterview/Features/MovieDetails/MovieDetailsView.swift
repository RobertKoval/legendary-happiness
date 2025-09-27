//
//  MovieDetailsView.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import SwiftUI

struct MovieDetailsView: View {
    @ObservedObject var viewModel: MovieDetailsViewModel

    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.vertical, UIConstants.Layout.catalogNavBarOffset)

            ZStack {
                switch viewModel.state {
                case .idle:
                    Color.clear
                        .onAppear { viewModel.loadMovieDetails() }

                case .loading:
                    SwiftUILoaderView()

                case .loaded(let movieDetails):
                    ScrollView(.vertical, showsIndicators: false) {
                        contentView(movieDetails: movieDetails)
                    }
                    .padding(.horizontal, 16)
                    .clipped()

                case .failed(let error):
                    errorView(error)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
    }

    private func contentView(movieDetails: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            posterView(movieDetails: movieDetails)
                .padding(.horizontal, UIConstants.Layout.movieDetailsPosterExtraHorizontalPadding)
                .padding(.bottom, 8)

            Text("Rating: \(movieDetails.rating)")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            Text(movieDetails.overview)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            Text(movieDetails.releaseDate)
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            favoriteButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }

    private func posterView(movieDetails: MovieDetails) -> some View {
        Image(uiImage: UIImage(data: movieDetails.imageData)!)
            .resizable()
            .aspectRatio(UIConstants.AspectRatio.detailsPosterAspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var favoriteButton: some View {
        Button(action: viewModel.onFavorite) {
            Text(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: UIConstants.Layout.favoriteButtonMinHeight)
        }
        .background(viewModel.isFavorite ? Color.clear : Color(.favorite))
        .foregroundColor(viewModel.isFavorite ? Color.text : Color.newBlack)
        .overlay(Capsule().stroke(Color.secondary, lineWidth: viewModel.isFavorite ? 2 : 0))
        .clipShape(Capsule())
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(.backIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.text)
            }

            Text(titleText)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.text)

            Spacer()
        }
        .frame(height: 60)
    }

    private var titleText: String {
        switch viewModel.state {
        case .loaded(let movieDetails):
            return movieDetails.title
        default:
            return viewModel.title
        }
    }

    private func errorView(_ error: EquatableError) -> some View {
        VStack {
            Spacer()
            Text("Failed to load movie details")
                .font(.headline)
                .foregroundColor(.primary)

            Text(error.base.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                viewModel.loadMovieDetails()
            }
            .foregroundColor(.blue)
            .padding()

            Spacer()
        }
    }
}
