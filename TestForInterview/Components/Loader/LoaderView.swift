//
//  LoaderView.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import UIKit

final class LoaderView: UIView {
    private let indicatorImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .background

        indicatorImageView.image = .indicator
        indicatorImageView.contentMode = .scaleAspectFit
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(indicatorImageView)

        NSLayoutConstraint.activate([
            indicatorImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorImageView.widthAnchor.constraint(equalToConstant: 80),
            indicatorImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func startAnimating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.0
        rotation.repeatCount = Float.infinity
        indicatorImageView.layer.add(rotation, forKey: "rotationAnimation")
    }

    func stopAnimating() {
        indicatorImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
