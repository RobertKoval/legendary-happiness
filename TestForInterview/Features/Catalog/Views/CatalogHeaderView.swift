//
//  CatalogHeaderView.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import UIKit

final class CatalogHeaderView: UICollectionReusableView {
    static let reuseId = "CatalogHeaderView"

    private static let title = "Movies"
    private static let averagePrefix = "Avg"

    var onSearch: (() -> Void)?
    var onTheme: (() -> Void)?
    var onFavorites: (() -> Void)?

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(
            ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2).pointSize,
            weight: .bold)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .text
        lbl.text = CatalogHeaderView.title
        return lbl
    }()

    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(.searchGlass, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.tintColor = .text
        return btn
    }()

    private let favoritesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(.starFull, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.tintColor = .text
        return btn
    }()

    private let themeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(.themeToggle, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.tintColor = .text
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = .background

        addSubview(titleLabel)
        addSubview(searchButton)
        addSubview(favoritesButton)
        addSubview(themeButton)

        // Layout
        let inset: CGFloat = 16
        let buttonSpacing: CGFloat = 16
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            themeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            themeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            themeButton.heightAnchor.constraint(equalToConstant: 24),
            themeButton.widthAnchor.constraint(equalTo: themeButton.heightAnchor),

            searchButton.trailingAnchor.constraint(
                equalTo: themeButton.leadingAnchor, constant: -buttonSpacing),
            searchButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchButton.heightAnchor.constraint(equalTo: themeButton.heightAnchor),
            searchButton.widthAnchor.constraint(equalTo: themeButton.widthAnchor),

            favoritesButton.trailingAnchor.constraint(
                equalTo: searchButton.leadingAnchor, constant: -buttonSpacing),
            favoritesButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            favoritesButton.heightAnchor.constraint(equalTo: themeButton.heightAnchor),
            favoritesButton.widthAnchor.constraint(equalTo: themeButton.widthAnchor),
        ])

        // Actions
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(didTapFavorites), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(didTapTheme), for: .touchUpInside)

        configure(averageRatingText: nil)
    }

    @objc private func didTapSearch() { onSearch?() }
    @objc private func didTapFavorites() { onFavorites?() }
    @objc private func didTapTheme() { onTheme?() }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(averageRatingText: nil)
    }

    func configure(averageRatingText: String?) {
        guard let averageRatingText else {
            titleLabel.text = CatalogHeaderView.title
            return
        }

        titleLabel.text =
            "\(CatalogHeaderView.title) | \(CatalogHeaderView.averagePrefix) \(averageRatingText)"
    }
}
