//
//  ViewController.swift
//  TestForInterview
//
//  Created by Sam Titovskyi on 18.08.2025.
//

import UIKit
import SwiftUI

final class CatalogViewController: UIViewController, Storyboarded {
    static var storyboardName: String = "Catalog"

    private let columns: Int = 2
    private let interSpacing: CGFloat = 16
    private let outerHorizontalSpacing: CGFloat = 16.5
    private let inset: CGFloat = 16
    private let headerHeight: CGFloat = 35
    private let headerTopOffset: CGFloat = 24
    private let navBarOffset: CGFloat = 33


    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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

    // MARK: - UI Setup
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = view.safeAreaInsets.top + navBarOffset

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = CGSize(width: 1, height: 1)
        }

        collectionView.register(CatalogHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CatalogHeaderView.reuseId)

        collectionView.register(CatalogMovieCell.self, forCellWithReuseIdentifier: CatalogMovieCell.reuseId)

        collectionView.reloadData()
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
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogMovieCell.reuseId,
                                                      for: indexPath) as! CatalogMovieCell
        cell.configure(title: "Test", rating: 2, posterURL: nil, isFavorite: indexPath.item % 2 == 0 ? true : false)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UIHostingController(rootView: EmptyView())
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

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
