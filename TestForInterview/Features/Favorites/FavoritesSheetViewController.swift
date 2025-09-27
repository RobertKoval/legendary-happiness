//
//  FavoritesSheetViewController.swift
//  TestForInterview
//
//  Created by Robert Koval on 27.09.2025.
//

import Combine
import UIKit

final class FavoritesSheetViewController: UIViewController {
    var viewModel: FavoritesViewModel!
    var dependencies: AppAssembly!
    var onDismiss: (() -> Void)?

    private enum Section {
        case grid
    }

    private enum Item: Hashable {
        case movie(Movie)
        case placeholder
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private var cancellables = Set<AnyCancellable>()
    private var dataSource: DataSource!
    private var hasAppliedInitialSnapshot = false

    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorites"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .text
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private let loaderView = LoaderView()
    private let emptyStateView = EmptyStateView(image: .notFound)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupPanGesture()
        viewModel.loadFavorites()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        MovieCollectionViewLayout.updateLayout(
            collectionView,
            configuration: .init(sectionTopInset: 16)
        )
    }

    // MARK: - Header Update
    private func updateHeader(with data: Movies?) {
        guard let data = data, let averageRatingText = data.averageRatingText else {
            titleLabel.text = "Favorites"
            return
        }
        titleLabel.text = "Favorites | Avg \(averageRatingText)"
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(handleView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        containerView.addSubview(collectionView)

        setupConstraints()
        setupCollectionView()
        setupLoaderView()
        setupEmptyState()

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85),

            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),

            handleView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),

            closeButton.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func setupCollectionView() {
        MovieCollectionViewLayout.setupCollectionView(collectionView)
        configureDataSource()
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) {
            [weak self] collectionView, indexPath, item in
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CatalogMovieCell.reuseId,
                    for: indexPath
                ) as? CatalogMovieCell,
                let self = self
            else {
                return UICollectionViewCell()
            }

            switch item {
            case .movie(let movie):
                cell.isHidden = false
                cell.isUserInteractionEnabled = true
                cell.configure(
                    title: movie.title,
                    rating: movie.rating,
                    posterURL: self.viewModel.posterURL(for: movie),
                    isFavorite: movie.isFavorite
                )

            case .placeholder:
                cell.isHidden = true
                cell.isUserInteractionEnabled = false
            }

            return cell
        }
    }

    private func setupLoaderView() {
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loaderView)

        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            loaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        loaderView.isHidden = true
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        emptyStateView.isHidden = true
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }

    private func bindViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ state: ViewState<Movies>) {
        switch state {
        case .idle:
            loaderView.isHidden = true
            loaderView.stopAnimating()
            emptyStateView.isHidden = true
            collectionView.isHidden = true
            updateHeader(with: nil)

        case .loading:
            loaderView.isHidden = false
            loaderView.startAnimating()
            emptyStateView.isHidden = true
            collectionView.isHidden = true

        case .loaded(let data):
            loaderView.isHidden = true
            loaderView.stopAnimating()
            updateHeader(with: data)

            if data.movies.isEmpty {
                emptyStateView.updateMessage("No favorites yet")
                emptyStateView.isHidden = false
                collectionView.isHidden = true
                applyEmptySnapshot()
            } else {
                emptyStateView.isHidden = true
                collectionView.isHidden = false
                applySnapshot(with: data)
            }

        case .failed:
            loaderView.isHidden = true
            loaderView.stopAnimating()
            updateHeader(with: nil)
            emptyStateView.updateMessage("Failed to load favorites")
            emptyStateView.isHidden = false
            collectionView.isHidden = true
            applyEmptySnapshot()
        }
    }

    private func applySnapshot(with movies: Movies) {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])

        let movieItems = movies.movies.map(Item.movie)
        snapshot.appendItems(movieItems, toSection: .grid)

        if movies.movies.count == 1 {
            snapshot.appendItems([.placeholder], toSection: .grid)
        }

        let shouldAnimate = hasAppliedInitialSnapshot
        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
        hasAppliedInitialSnapshot = true
    }

    private func applyEmptySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])
        dataSource.apply(snapshot, animatingDifferences: hasAppliedInitialSnapshot)
    }

    // MARK: - Actions
    @objc private func closeTapped() {
        dismissWithAnimation()
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }

        case .ended, .cancelled:
            let shouldDismiss = translation.y > 100 || velocity.y > 500

            if shouldDismiss {
                dismissWithAnimation()
            } else {
                UIView.animate(
                    withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0
                ) {
                    self.containerView.transform = .identity
                }
            }

        default:
            break
        }
    }

    private func dismissWithAnimation() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.containerView.transform = CGAffineTransform(
                    translationX: 0, y: self.view.bounds.height)
            }
        ) { _ in
            self.dismiss(animated: false) { [weak self] in
                self?.onDismiss?()
            }
        }
    }

    // MARK: - Presentation
    static func presentModally(
        from presenter: UIViewController,
        dependencies: AppAssembly,
        onDismiss: (() -> Void)? = nil
    ) {
        let favoritesViewController = dependencies.makeFavoritesSheetViewController(
            onDismiss: onDismiss)

        let navigationController = UINavigationController(
            rootViewController: favoritesViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve

        favoritesViewController.loadViewIfNeeded()
        favoritesViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        favoritesViewController.containerView.transform = CGAffineTransform(
            translationX: 0,
            y: presenter.view.bounds.height
        )

        presenter.present(navigationController, animated: true) {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0
            ) {
                favoritesViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                favoritesViewController.containerView.transform = .identity
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FavoritesSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .placeholder:
            return
        case .movie(let movie):
            presentMovieDetails(movieId: movie.id)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch item {
        case .placeholder:
            return nil
        case .movie(let movie):
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let removeAction = UIAction(
                    title: "Remove from Favorites",
                    image: UIImage(systemName: "heart.slash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.viewModel.removeFavorite(movieId: movie.id)
                }

                return UIMenu(title: "", children: [removeAction])
            }
        }
    }

    private func presentMovieDetails(movieId: Int) {
        let cachedDetailsDTO = viewModel.getCachedDetailsDTO(for: movieId)
        let controller = dependencies.makeMovieDetailsViewController(
            movieId: movieId,
            onBack: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
                self.viewModel.loadFavorites()
            },
            cachedDetailsDTO: cachedDetailsDTO
        )

        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavoritesSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
