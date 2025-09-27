//
//  CatalogPaginationFooterView.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import UIKit

final class CatalogPaginationFooterView: UICollectionReusableView {
    static let reuseId = "CatalogPaginationFooterView"

    private let maxVisiblePages = UIConstants.Layout.paginationMaxVisiblePages
    private let buttonSize: CGFloat = UIConstants.Layout.paginationButtonSize
    private let buttonSpacing: CGFloat = UIConstants.Layout.paginationButtonSpacing
    private let dotsNumber = -1  // number in the array of pages.

    private var currentPage = 1
    private var totalPages = 1
    private var onPageSelected: ((Int) -> Void)?

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = buttonSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
    }

    func configure(currentPage: Int, totalPages: Int, onPageSelected: @escaping (Int) -> Void) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onPageSelected = onPageSelected

        setupPageButtons()
    }

    private func setupPageButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let pages = calculateVisiblePages()

        for page in pages {
            if page == dotsNumber {
                let dotsLabel = createDotsLabel()
                stackView.addArrangedSubview(dotsLabel)
            } else {
                let button = createPageButton(page: page)
                stackView.addArrangedSubview(button)
            }
        }
    }

    private func calculateVisiblePages() -> [Int] {
        guard totalPages > 1 else { return [] }

        // Fit them all.
        if totalPages <= 5 {
            return Array(1...totalPages)
        }

        var pages: [Int] = []

        // Always show first page
        pages.append(1)

        // Calculate the middle range around current page
        let middleStart: Int
        let middleEnd: Int

        if currentPage <= 3 {
            // Near beginning: [1] [2] [3] [4] ... [N]
            middleStart = 2
            middleEnd = 4
        } else if currentPage >= totalPages - 2 {
            // Near end: [1] ... [N-3] [N-2] [N-1] [N]
            middleStart = totalPages - 3
            middleEnd = totalPages - 1
        } else {
            // In middle: [1] ... [current-1] [current] [current+1] ... [N]
            middleStart = currentPage - 1
            middleEnd = currentPage + 1
        }

        // Add dots if needed before middle range
        if middleStart > 2 {
            pages.append(dotsNumber)
        }

        // Add middle range
        for page in middleStart...middleEnd {
            if page > 1 && page < totalPages {
                pages.append(page)
            }
        }

        // Add dots if needed after middle range
        if middleEnd < totalPages - 1 {
            pages.append(dotsNumber)
        }

        // Always show last page (if > 1)
        if totalPages > 1 {
            pages.append(totalPages)
        }

        return pages
    }

    private func createPageButton(page: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(page)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonSize),
            button.heightAnchor.constraint(equalToConstant: buttonSize),
        ])

        if page == currentPage {
            button.backgroundColor = .favorite
            button.setTitleColor(.newBlack, for: .normal)
            button.layer.cornerRadius = buttonSize / 2
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.text, for: .normal)
            button.layer.cornerRadius = buttonSize / 2
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(resource: .text).cgColor
        }

        button.addTarget(self, action: #selector(pageButtonTapped(_:)), for: .touchUpInside)
        button.tag = page

        return button
    }

    private func createDotsLabel() -> UILabel {
        let label = UILabel()
        label.text = "..."
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .text
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 16),
            label.heightAnchor.constraint(equalToConstant: buttonSize),
        ])

        return label
    }

    @objc private func pageButtonTapped(_ sender: UIButton) {
        let page = sender.tag
        guard page != currentPage else { return }

        onPageSelected?(page)
    }
}
