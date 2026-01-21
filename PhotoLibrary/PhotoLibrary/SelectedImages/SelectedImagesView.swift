//
//  SelectedImagesView.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 21/01/2026.
//

import SwiftUI

struct SelectedImagesView: View {
    @StateObject var viewModel: SelectedImagesViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.selectedImages, id: \.localIdentifier) { asset in
                    if let image = viewModel.getImage(asset: asset,
                                                      size: CGSize(width: 400,
                                                                   height: 200)) {
                        Image(uiImage: image)
                            .resizable()
                            .padding()

                    }
                }
            }
        }
        .frame(height: 400)
        .onAppear {
            if let firstImage = viewModel.selectedImages.first {
                let data = viewModel.getCompressedData(asset: firstImage)
                print(data)
            }
        }
    }
}

#Preview {
    SelectedImagesView(viewModel: SelectedImagesViewModel(selectedImages: [],
                                                          coordinator: PhotoLibraryCoordiantor()))
}
