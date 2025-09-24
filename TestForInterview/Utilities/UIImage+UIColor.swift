//
//  UIImage+UIColor.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import UIKit

extension UIImage {
    static func from(color: UIColor,
                     size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
