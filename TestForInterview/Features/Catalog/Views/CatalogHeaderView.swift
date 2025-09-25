//
//  CatalogHeaderView.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import UIKit

final class CatalogHeaderView: UICollectionReusableView {
    static let reuseId = "CatalogHeaderView"

    var onSearch: (() -> Void)?
    var onTheme: (() -> Void)?

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2).pointSize, weight: .bold)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .text
        lbl.text = "Movie"
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
        backgroundColor = .systemBackground

        addSubview(titleLabel)
        addSubview(searchButton)
        addSubview(themeButton)

        // Layout
        let inset: CGFloat = 16
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            themeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            themeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            themeButton.heightAnchor.constraint(equalToConstant: 24),
            themeButton.widthAnchor.constraint(equalTo: themeButton.heightAnchor),

            searchButton.trailingAnchor.constraint(equalTo: themeButton.leadingAnchor, constant: -24),
            searchButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchButton.heightAnchor.constraint(equalTo: themeButton.heightAnchor),
            searchButton.widthAnchor.constraint(equalTo: themeButton.widthAnchor),
        ])

        // Actions
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(didTapTheme), for: .touchUpInside)
    }

    @objc private func didTapSearch() { onSearch?() }
    @objc private func didTapTheme() { onTheme?() }
}
