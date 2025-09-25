//
//  ViewController.swift
//  TestForInterview
//
//  Created by Sam Titovskyi on 18.08.2025.
//

import UIKit
import SwiftUI
import Combine

final class CatalogViewController: UIViewController, Storyboarded {
    static var storyboardName: String = "Catalog"

    private let columns: Int = UIConstants.Layout.catalogColumns
    private let interSpacing: CGFloat = 16
    private let outerHorizontalSpacing: CGFloat = UIConstants.Layout.catalogOuterHorizontalSpacing
    private let inset: CGFloat = 16
    private let headerHeight: CGFloat = UIConstants.Layout.catalogHeaderHeight
    private let headerTopOffset: CGFloat = UIConstants.Layout.catalogHeaderTopOffset
    private let navBarOffset: CGFloat = UIConstants.Layout.catalogNavBarOffset

    var viewModel: CatalogViewModel!

    private var cancellables = Set<AnyCancellable>()

    @IBOutlet private weak var collectionView: UICollectionView!
    private let loaderView = LoaderView()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        viewModel.fetchMovies()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let insets = UIEdgeInsets(top: headerTopOffset,
                                      left: outerHorizontalSpacing,
                                      bottom: 0,
                                      right: outerHorizontalSpacing)
            let total = insets.left + insets.right + interSpacing * (CGFloat(columns) - 1)
            let w = floor(collectionView.bounds.width - total) / CGFloat(columns)
            flow.minimumInteritemSpacing = interSpacing
            flow.minimumLineSpacing = interSpacing
            flow.sectionInset = insets
            flow.estimatedItemSize = CGSize(width: w,
                                            height: collectionView.bounds.height) // height will be estimated
        }
    }

    // MARK: - Setup
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = view.safeAreaInsets.top + navBarOffset
        collectionView.refreshControl = refreshControl

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = CGSize(width: 1, height: 1)
        }

        collectionView.register(CatalogHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CatalogHeaderView.reuseId)

        collectionView.register(CatalogMovieCell.self, forCellWithReuseIdentifier: CatalogMovieCell.reuseId)

        setupLoaderView()
    }

    private func setupLoaderView() {
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)

        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loaderView.startAnimating()
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .idle, .loading:
                    self.loaderView.isHidden = false
                    self.loaderView.startAnimating()

                case .loaded:
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                    self.loaderView.isHidden = true
                    self.loaderView.stopAnimating()

                case .failed(let error):
                    // Error occurred
                    self.loaderView.isHidden = true
                    self.loaderView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    // TODO: Show error state
                    print("Error loading movies: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.refreshMovies()
    }

    @objc private func searchTapped() { /* push search VC */ }
    @objc private func themeTapped() { /* present favorites */ }
}

// MARK: - UICollectionViewDataSource
extension CatalogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CatalogHeaderView.reuseId,
            for: indexPath
        ) as! CatalogHeaderView

        header.onSearch = { [weak self] in self?.searchTapped() }
        header.onTheme = { [weak self] in self?.themeTapped() }
        header.configure(averageRatingText: viewModel.averageRatingText)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard case let .loaded(data) = viewModel.state else { return 0 }
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogMovieCell.reuseId,
                                                      for: indexPath) as! CatalogMovieCell

        guard case let .loaded(data) = viewModel.state, indexPath.item < data.count else {
            fatalError("Data inconsistency.!!!")
        }

        let movie = data.movies[indexPath.item]
        cell.configure(
            title: movie.title,
            rating: movie.rating,
            posterURL: viewModel.posterURLForMovieAt(index: indexPath.item),
            isFavorite: movie.isFavorite
        )

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .loaded(data) = viewModel.state, indexPath.item < data.count else {
            fatalError("Data inconsistency.!!!")
        }

        let movie = data.movies[indexPath.item]

        // TODO: Create dependencies in the another place.
        let api = TMDBClient.live
        let localStorage = LocalStorage.live

        let movieDetailsViewModel = MovieDetailsViewModel(
            movieId: movie.id,
            movieTitle: movie.title,
            api: api,
            localStorage: localStorage
        )

        let movieDetailsView = MovieDetailsView(viewModel: movieDetailsViewModel) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        let hostingController = UIHostingController(rootView: movieDetailsView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: headerTopOffset,
                            left: outerHorizontalSpacing,
                            bottom: 0,
                            right: outerHorizontalSpacing)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interSpacing
    }
}
