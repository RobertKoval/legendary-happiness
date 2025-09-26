//
//  SearchViewController.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import UIKit
import Combine

final class InsetTextField: UITextField {
    /// Space from the text field's left boundary to the icon
    var contentLeadingPadding: CGFloat = 16
    /// Extra space between the icon (leftView) and the text/placeholder
    var textGapFromIcon: CGFloat = 4
    /// Optional: space from right boundary to rightView / clear button
    var contentTrailingPadding: CGFloat = 0

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += contentLeadingPadding
        return rect
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // super already accounts for leftView width; we only add the gap after it
        let r = super.textRect(forBounds: bounds)
        return r.inset(by: UIEdgeInsets(top: 0, left: textGapFromIcon, bottom: 0, right: contentTrailingPadding))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let r = super.editingRect(forBounds: bounds)
        return r.inset(by: UIEdgeInsets(top: 0, left: textGapFromIcon, bottom: 0, right: contentTrailingPadding))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let r = super.placeholderRect(forBounds: bounds)
        return r.inset(by: UIEdgeInsets(top: 0, left: textGapFromIcon, bottom: 0, right: contentTrailingPadding))
    }
}

final class SearchViewController: UIViewController {
    var viewModel: SearchViewModel!
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
    private let emptyStateMessage = "Nothing found"
    private let sectionTopInset: CGFloat = 16

    private var dataSource: DataSource!
    private var currentMovies: Movies?
    private var lastAppliedPage: Int?
    private var lastSnapshotQuery: String?
    private var hasAppliedInitialSnapshot = false

    // MARK: - UI Elements
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(.backIcon, for: .normal)
        btn.tintColor = .text
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Search"
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        lbl.textColor = .text
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let searchTextField: UITextField = {
        let search = InsetTextField()
        let icon = UIImage.searchGlass
        let imgView = UIImageView(frame: .init(x: 0, y: 0, width: 20, height: 20))

        imgView.isUserInteractionEnabled = false
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = .text
        imgView.image = icon

        search.placeholder = "Search"
        search.backgroundColor = .systemGray6
        search.keyboardType = .default
        search.returnKeyType = .search
        search.clearButtonMode = .whileEditing
        search.autocorrectionType = .no
        search.autocapitalizationType = .none
        search.layer.cornerRadius = 10
        search.leftView = imgView
        search.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        search.leftViewMode = .always
        search.rightViewMode = .always
        search.translatesAutoresizingMaskIntoConstraints = false
        search.font = UIFont.systemFont(ofSize: 16)
        search.textColor = .text

        return search
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .background
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    private let loaderView = LoaderView()
    private let emptyStateView = EmptyStateView(image: .notFound)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent else { return }
        onDismiss?()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .background
        setupNavigationBar()
        setupHeader()
        setupSearchField()
        setupCollectionView()
        setupLoaderView()
        setupEmptyState()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.Layout.catalogNavBarOffset),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16)
        ])

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func setupSearchField() {
        view.addSubview(searchTextField)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 50)
        ])

        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        MovieCollectionViewLayout.setupCollectionView(collectionView)

        collectionView.register(SearchHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SearchHeaderView.reuseId)

        collectionView.register(CatalogPaginationFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: CatalogPaginationFooterView.reuseId)

        configureDataSource()
    }

    private func setupLoaderView() {
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)

        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loaderView.isHidden = true
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        emptyStateView.isHidden = true
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
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

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SearchHeaderView.reuseId,
                    for: indexPath
                ) as! SearchHeaderView

                if let movies = self.currentMovies, !movies.movies.isEmpty {
                    header.configure(resultsCount: movies.totalResults)
                }

                return header

            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CatalogPaginationFooterView.reuseId,
                    for: indexPath
                ) as! CatalogPaginationFooterView

                if let movies = self.currentMovies {
                    footer.configure(currentPage: movies.page, totalPages: movies.totalPages) { [weak self] page in
                        self?.viewModel.loadPage(page)
                    }
                }

                return footer

            default:
                return nil
            }
        }
    }

    private func applySnapshot(with movies: Movies, query: String) {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])

        let movieItems = movies.movies.map(Item.movie)
        snapshot.appendItems(movieItems, toSection: .grid)

        if movies.movies.count == 1 {
            snapshot.appendItems([.placeholder], toSection: .grid)
        }

        let shouldScroll = shouldScrollToTop(newPage: movies.page, query: query)
        let shouldAnimate = hasAppliedInitialSnapshot && !shouldScroll

        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)

        hasAppliedInitialSnapshot = true
        lastAppliedPage = movies.page
        lastSnapshotQuery = query

        if shouldScroll {
            scrollToTop()
        }
    }

    private func applyEmptySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])
        dataSource.apply(snapshot, animatingDifferences: hasAppliedInitialSnapshot)
        currentMovies = nil
        lastAppliedPage = nil
        lastSnapshotQuery = nil
    }

    private func shouldScrollToTop(newPage: Int, query: String) -> Bool {
        if lastSnapshotQuery != query { return true }
        guard let lastPage = lastAppliedPage else { return true }
        return newPage != lastPage
    }

    private func applyLayout() {
        MovieCollectionViewLayout.updateLayout(
            collectionView,
            configuration: .init(sectionTopInset: sectionTopInset)
        )
    }

    private func bindViewModel() {
        viewModel.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)

        // Bind search text
        viewModel.$searchText
            .sink { [weak self] text in
                if self?.searchTextField.text != text {
                    self?.searchTextField.text = text
                }
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ state: ViewState<Movies>) {
        switch state {
        case .idle:
            loaderView.isHidden = true
            loaderView.stopAnimating()
            emptyStateView.updateMessage(nil)
            emptyStateView.isHidden = true
            collectionView.isHidden = true
            applyEmptySnapshot()

        case .loading:
            loaderView.isHidden = false
            loaderView.startAnimating()
            emptyStateView.updateMessage(nil)
            emptyStateView.isHidden = true
            collectionView.isHidden = true

        case .loaded(let data):
            loaderView.isHidden = true
            loaderView.stopAnimating()

            if data.movies.isEmpty {
                currentMovies = nil
                emptyStateView.updateMessage(emptyStateMessage)
                emptyStateView.isHidden = false
                collectionView.isHidden = true
                applyEmptySnapshot()
            } else {
                currentMovies = data
                emptyStateView.updateMessage(nil)
                emptyStateView.isHidden = true
                collectionView.isHidden = false
                applySnapshot(with: data, query: viewModel.searchText)
            }

        case .failed:
            loaderView.isHidden = true
            loaderView.stopAnimating()
            emptyStateView.updateMessage(nil)
            emptyStateView.isHidden = false
            collectionView.isHidden = true
            applyEmptySnapshot()
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func searchTextChanged() {
        viewModel.searchText = searchTextField.text ?? ""
    }

    private func scrollToTop() {
        let topOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
        collectionView.setContentOffset(topOffset, animated: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Show header only when results are available; hide for empty, idle, loading, or failed states
        guard let movies = currentMovies, !movies.movies.isEmpty else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: UIConstants.Layout.catalogHeaderHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let movies = currentMovies, movies.totalPages > 1 else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .placeholder:
            return
        case .movie(let movie):
            presentMovieDetails(movieId: movie.id)
        }
    }
}

// MARK: - Navigation
extension SearchViewController {
    func presentMovieDetails(movieId: Int) {
        let controller = dependencies.makeMovieDetailsViewController(movieId: movieId) { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.viewModel.refreshFavorites()
        }

        navigationController?.pushViewController(controller, animated: true)
    }
}
