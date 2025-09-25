//
//  ViewState.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import Foundation

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case failed(EquatableError)
}
