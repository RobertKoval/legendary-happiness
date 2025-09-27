//
//  EmptyStateView.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import UIKit

final class EmptyStateView: UIView {
    private let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = .text
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .text
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(image: UIImage?, message: String? = nil) {
        super.init(frame: .zero)
        backgroundColor = .background
        imageView.image = image
        setupLayout()
        updateMessage(message)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
        ])

        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }

    func updateMessage(_ message: String?) {
        let trimmed = message?.trimmingCharacters(in: .whitespacesAndNewlines)
        messageLabel.text = trimmed
        messageLabel.isHidden = trimmed?.isEmpty ?? true
    }
}
