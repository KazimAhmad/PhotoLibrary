//
//  ContentView.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 19/01/2026.
//

import SwiftUI

struct PhotoLibraryView<ViewModel: PhotoLibraryViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    var columns: [GridItem] = [.init(.adaptive(minimum: 100)),
                               .init(.adaptive(minimum: 100)),
                               .init(.adaptive(minimum: 100))]
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                viewModel.goToAlbums()
            } label: {
                HStack {
                    Text(viewModel.selectedAlbum?.localizedTitle ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(Color.primary)
            }

            ScrollView {
                LazyVGrid(columns: columns,
                          alignment: .center,
                          spacing: 8,
                          pinnedViews: .sectionHeaders,
                          content: {
                    ForEach(viewModel.photosInRecentAlbum, id: \.self) { photo in
                        if let image = viewModel.getThumbnail(asset: photo,
                                                           size: CGSize(width: 200,
                                                                        height: 200)) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(height: 200)
                                .onTapGesture {
                                    viewModel.showImage(image: image)
                                }
                        }
                    }
                })
            }
        }
        .padding()
        .onAppear {
            viewModel.getPhotosPermission()
        }
        .onChange(of: viewModel.selectedAlbum) { _, _ in
            viewModel.updatePictures()
        }
    }
}

#Preview {
    PhotoLibraryView(viewModel: PhotoLibraryViewModel(coordinator: PhotoLibraryCoordiantor()))
}
