//
//  ViewController.swift
//  TestForInterview
//
//  Created by Sam Titovskyi on 18.08.2025.
//

import Combine
import SwiftUI
import UIKit

final class CatalogViewController: UIViewController, Storyboarded {
    static var storyboardName: String = "Catalog"

    private let headerHeight: CGFloat = UIConstants.Layout.catalogHeaderHeight
    private let headerTopOffset: CGFloat = UIConstants.Layout.catalogHeaderTopOffset
    private let navBarOffset: CGFloat = UIConstants.Layout.catalogNavBarOffset

    private enum Section {
        case grid
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

    var viewModel: CatalogViewModel!
    var appAssembly: AppAssembly!

    private var cancellables = Set<AnyCancellable>()
    private var dataSource: DataSource!
    private var lastDisplayedPage: Int?
    private var hasAppliedInitialSnapshot = false

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
        MovieCollectionViewLayout.updateLayout(
            collectionView,
            configuration: .init(sectionTopInset: headerTopOffset)
        )
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .background
        navigationController?.navigationBar.isHidden = true
        collectionView.delegate = self
        collectionView.contentInset.top = view.safeAreaInsets.top + navBarOffset
        collectionView.refreshControl = refreshControl

        MovieCollectionViewLayout.setupCollectionView(collectionView)

        collectionView.register(
            CatalogHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CatalogHeaderView.reuseId)

        collectionView.register(
            CatalogPaginationFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: CatalogPaginationFooterView.reuseId)

        configureDataSource()
        setupLoaderView()
    }

    private func setupLoaderView() {
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)

        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loaderView.startAnimating()
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) {
            [weak self] collectionView, indexPath, movie in
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CatalogMovieCell.reuseId,
                    for: indexPath
                ) as? CatalogMovieCell,
                let self = self
            else {
                return UICollectionViewCell()
            }

            cell.configure(
                title: movie.title,
                rating: movie.rating,
                posterURL: self.viewModel.posterURL(for: movie),
                isFavorite: movie.isFavorite
            )

            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header =
                    collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: CatalogHeaderView.reuseId,
                        for: indexPath
                    ) as! CatalogHeaderView

                header.onSearch = { [weak self] in self?.searchTapped() }
                header.onFavorites = { [weak self] in self?.favoritesTapped() }
                header.onTheme = { [weak self] in self?.themeTapped() }
                header.configure(averageRatingText: self.viewModel.averageRatingText)
                return header

            case UICollectionView.elementKindSectionFooter:
                let footer =
                    collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: CatalogPaginationFooterView.reuseId,
                        for: indexPath
                    ) as! CatalogPaginationFooterView

                guard case let .loaded(movies) = self.viewModel.state else {
                    footer.configure(currentPage: 1, totalPages: 1, onPageSelected: { _ in })
                    return footer
                }

                footer.configure(currentPage: movies.page, totalPages: movies.totalPages) {
                    [weak self] page in
                    self?.viewModel.loadPage(page)
                }
                return footer

            default:
                return nil
            }
        }
    }

    private func applySnapshot(with movies: Movies) {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])
        snapshot.appendItems(movies.movies, toSection: .grid)

        let shouldScroll = shouldScrollToTop(for: movies.page)
        let shouldAnimate = hasAppliedInitialSnapshot && !shouldScroll

        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)

        hasAppliedInitialSnapshot = true
        lastDisplayedPage = movies.page

        if shouldScroll {
            scrollToTop()
        }
    }

    private func shouldScrollToTop(for newPage: Int) -> Bool {
        guard let lastPage = lastDisplayedPage else { return true }
        return newPage != lastPage
    }

    private func bindViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .idle, .loading:
                    self.loaderView.isHidden = false
                    self.loaderView.startAnimating()

                case .loaded(let data):
                    self.refreshControl.endRefreshing()
                    self.applySnapshot(with: data)
                    self.loaderView.isHidden = true
                    self.loaderView.stopAnimating()
                    self.updateHeaderIfVisible(with: data)

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

    private func scrollToTop() {
        let topOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
        collectionView.setContentOffset(topOffset, animated: false)
    }

    private func updateHeaderIfVisible(with data: Movies) {
        // Update the header with current average rating if it's visible
        let headerIndexPath = IndexPath(item: 0, section: 0)
        if let headerView = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath)
            as? CatalogHeaderView
        {
            headerView.configure(averageRatingText: data.averageRatingText)
        }
    }

    @objc private func searchTapped() {
        let searchViewController = appAssembly.makeSearchViewController { [weak self] in
            self?.viewModel.refreshFavorites()
        }
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    @objc private func favoritesTapped() {
        FavoritesSheetViewController.presentModally(
            from: self,
            appAssembly: appAssembly,
            onDismiss: { [weak self] in
                self?.viewModel.refreshFavorites()
            })
    }

    @objc private func themeTapped() {
        let alert = UIAlertController(
            title: "App Theme", message: nil, preferredStyle: .actionSheet)

        Theme.allCases.forEach { theme in
            let isCurrent = theme == viewModel.currentTheme
            let title = isCurrent ? "\(theme.title) ✓" : theme.title
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.setTheme(theme)
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.safeAreaInsets.top + UIConstants.Layout.catalogNavBarOffset,
                width: 1,
                height: 1
            )
        }

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else {
            fatalError("Data inconsistency.!!!")
        }
        presentMovieDetails(movieId: movie.id, title: movie.title)
    }

    func collectionView(
        _ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let favoriteAction = UIAction(
                title: movie.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                image: UIImage(systemName: movie.isFavorite ? "heart.slash" : "heart"),
                attributes: movie.isFavorite ? .destructive : []
            ) { [weak self] _ in
                self?.viewModel.toggleFavorite(movieId: movie.id)
            }

            return UIMenu(title: "", children: [favoriteAction])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: headerHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard case let .loaded(data) = viewModel.state, data.totalPages > 1 else {
            return .zero
        }
        return CGSize(
            width: collectionView.bounds.width, height: UIConstants.Layout.paginationFooterHeight)
    }
}

// MARK: - Navigation
extension CatalogViewController {
    private func presentMovieDetails(movieId: Int, title: String) {
        let controller = appAssembly.makeMovieDetailsViewController(
            movieId: movieId, movieTitle: title
        ) {
            [weak self] in
            self?.navigationController?.popViewController(animated: true)
            self?.viewModel.refreshFavorites()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}
