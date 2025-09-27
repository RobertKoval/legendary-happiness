//
//  SearchHeaderView.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import UIKit

final class SearchHeaderView: UICollectionReusableView {
    static let reuseId = "SearchHeaderView"

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lbl.adjustsFontForContentSizeCategory = true
        lbl.textColor = .text
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = .background
        addSubview(titleLabel)

        let inset: CGFloat = 16
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -inset),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(resultsCount: Int) {
        titleLabel.text = "Search results (\(resultsCount))"
    }
}
