//
//  CatalogMovieCell.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import SDWebImage
import UIKit

final class CatalogMovieCell: UICollectionViewCell {
    static let reuseId = "CatalogMovieCell"

    private let posterImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = UIConstants.CornerRadius.poster
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private let favoriteIconView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private let textContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.numberOfLines = 2
        lbl.textColor = .text
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let ratingLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = .text
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(favoriteIconView)
        contentView.addSubview(textContainer)
        textContainer.addSubview(nameLabel)
        textContainer.addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor,
                multiplier: UIConstants.AspectRatio.catalogPosterHeightMultiplier),

            favoriteIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteIconView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -14),
            favoriteIconView.widthAnchor.constraint(
                equalToConstant: UIConstants.IconSize.favoriteIcon),
            favoriteIconView.heightAnchor.constraint(
                equalToConstant: UIConstants.IconSize.favoriteIcon),

            textContainer.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 4),
            textContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textContainer.heightAnchor.constraint(equalToConstant: 52),

            nameLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
        ])

        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        ratingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func configure(title: String, rating: Double, posterURL: URL?, isFavorite: Bool) {
        nameLabel.text = title
        ratingLabel.text = "Rating: \(rating)"
        favoriteIconView.image = isFavorite ? .starFull : .starEmpty

        posterImageView.sd_setImage(
            with: posterURL,
            placeholderImage: UIImage(
                data: ImagePlaceholderGenerator.live.generatePosterPlaceholder())
        )
    }

    override func preferredLayoutAttributesFitting(_ attrs: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes
    {
        setNeedsLayout()
        layoutIfNeeded()
        let target = CGSize(
            width: attrs.size.width, height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        attrs.size = size
        return attrs
    }
}
