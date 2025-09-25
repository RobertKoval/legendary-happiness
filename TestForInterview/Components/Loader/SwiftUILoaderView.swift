//
//  SwiftUILoaderView.swift
//  TestForInterview
//
//  Created by Robert Koval on 25.09.2025.
//

import SwiftUI

struct SwiftUILoaderView: View {
    var body: some View {
        LoaderViewRepresentable()
            .frame(width: UIConstants.IconSize.loaderSize, height: UIConstants.IconSize.loaderSize)
    }
}

private struct LoaderViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> LoaderView {
        let loader = LoaderView()
        loader.startAnimating()
        return loader
    }

    func updateUIView(_ uiView: LoaderView, context: Context) {
        // TODO: Do we need to stop it?
    }
}
