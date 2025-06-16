//
//  ImageView.swift
//  Product
//

import SwiftUI

struct ImageView: View {
    
    @StateObject var viewModel: ImageViewModel
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
    }
}
