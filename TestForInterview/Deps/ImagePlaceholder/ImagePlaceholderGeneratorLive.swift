//
//  ImagePlaceholderGeneratorLive.swift
//  TestForInterview
//
//  Created by Robert Koval on 26.09.2025.
//

import UIKit

extension ImagePlaceholderGenerator {
    static let live = ImagePlaceholderGenerator {
        struct Cache {
            static let data: Data = {
                // Poster aspect ratio 2:3 (200x300)
                let size = CGSize(width: 200, height: 300)
                let renderer = UIGraphicsImageRenderer(size: size)

                let image = renderer.image { ctx in
                    let rect = CGRect(origin: .zero, size: size)

                    // Background - lighter by 1 tone
                    UIColor.systemGray4.setFill()
                    ctx.fill(rect)

                    // Border
                    UIColor.systemGray3.setStroke()
                    ctx.cgContext.stroke(rect, width: 1)

                    // Center the .notFound icon - bigger size
                    let notFound = UIImage.notFound
                    let iconSize: CGFloat = 80
                    let iconRect = CGRect(
                        x: (size.width - iconSize) / 2,
                        y: (size.height - iconSize) / 2,
                        width: iconSize,
                        height: iconSize
                    )

                    // Bigger circle background around icon
                    let circleSize = iconSize + 32  // 16px padding on each side
                    let circleBg = CGRect(
                        x: (size.width - circleSize) / 2,
                        y: (size.height - circleSize) / 2,
                        width: circleSize,
                        height: circleSize
                    )
                    UIColor.systemBackground.withAlphaComponent(0.8).setFill()
                    ctx.cgContext.fillEllipse(in: circleBg)

                    // Draw the icon
                    notFound.withTintColor(.systemGray3).draw(in: iconRect)

                }
                return image.pngData() ?? Data()
            }()
        }
        return Cache.data
    }
}
