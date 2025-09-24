//
//  Storyboarded.swift
//  TestForInterview
//
//  Created by Robert Koval on 24.09.2025.
//

import UIKit

protocol Storyboarded {
    static var storyboardName: String { get }
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let sb = UIStoryboard(name: storyboardName, bundle: .main)
        guard let vc = sb.instantiateViewController(withIdentifier: id) as? Self else {
            fatalError("Failed to instantiate \(id) from \(storyboardName)")
        }
        return vc
    }
}
