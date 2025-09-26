//
//  MovieCollectionViewLayout.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import UIKit

struct MovieCollectionViewLayout {

    struct Configuration {
        let columns: Int
        let sectionTopInset: CGFloat
        let horizontalInset: CGFloat
        let interitemSpacing: CGFloat

        init(columns: Int = UIConstants.Layout.catalogColumns,
             sectionTopInset: CGFloat,
             horizontalInset: CGFloat = UIConstants.Layout.catalogOuterHorizontalSpacing,
             interitemSpacing: CGFloat = UIConstants.Layout.catalogInteritemSpacing) {
            self.columns = max(1, columns)
            self.sectionTopInset = sectionTopInset
            self.horizontalInset = horizontalInset
            self.interitemSpacing = interitemSpacing
        }
    }

    private static let supplementaryHeight: CGFloat = UIConstants.Layout.catalogCellSupplementaryHeight

    static func setupCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(CatalogMovieCell.self, forCellWithReuseIdentifier: CatalogMovieCell.reuseId)
        collectionView.backgroundColor = .background

        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flow.itemSize = UICollectionViewFlowLayout.automaticSize
        flow.sectionInsetReference = .fromContentInset
    }

    static func updateLayout(_ collectionView: UICollectionView, configuration: Configuration) {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let columns = CGFloat(max(1, configuration.columns))
        let availableWidth = collectionView.bounds.width
        guard availableWidth > 0 else { return }

        let totalSpacing = configuration.horizontalInset * 2 + configuration.interitemSpacing * (columns - 1)
        let availableForItems = availableWidth - totalSpacing
        guard availableForItems > 0 else { return }

        let itemWidth = floor(availableForItems / columns)
        let estimatedHeight = itemWidth * UIConstants.AspectRatio.catalogPosterHeightMultiplier + supplementaryHeight

        flow.minimumInteritemSpacing = configuration.interitemSpacing
        flow.minimumLineSpacing = configuration.interitemSpacing
        flow.sectionInset = UIEdgeInsets(top: configuration.sectionTopInset,
                                         left: configuration.horizontalInset,
                                         bottom: 0,
                                         right: configuration.horizontalInset)
        flow.estimatedItemSize = CGSize(width: itemWidth, height: estimatedHeight)
    }
}
