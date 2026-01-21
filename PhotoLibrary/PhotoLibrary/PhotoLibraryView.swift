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
            if viewModel.viewState == .error {
                alertView()
            } else {
                photosView()
                if viewModel.selectedImages.count > 0 {
                    nextButtonView()
                }
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
    
    func photosView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    viewModel.goToAlbums()
                } label: {
                    HStack {
                        Text(viewModel.selectedAlbum?.localizedTitle ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.down")
                    }
                }
                Spacer()
                Button {
                    viewModel.selection.toggle()
                    viewModel.selectedImages.removeAll()
                } label: {
                    Image(systemName: "square.on.square")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Select")
                }
            }
            .foregroundStyle(Color.primary)

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
                                    if viewModel.selection {
                                        viewModel.imageSelection(for: photo)
                                    } else {
                                        viewModel.showImage(image: image)
                                    }
                                }
                                .overlay {
                                    if viewModel.selection {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: viewModel.isSelected(photo: photo) ? "checkmark.circle.fill" : "circle")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                    .foregroundStyle(Color.blue)
                                            }
                                            .padding()
                                            Spacer()
                                        }
                                    }
                                }
                        }
                    }
                })
            }
        }
    }
    
    func alertView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.red)
            Text("Give permission to access your photo library")
            Button {
                viewModel.openSettings()
            } label: {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary)
                    )
            }
        }
    }
    
    func nextButtonView() -> some View {
        HStack {
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "arrow.right")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.primary)
                    )
            }
        }
    }
}

#Preview {
    PhotoLibraryView(viewModel: PhotoLibraryViewModel(coordinator: PhotoLibraryCoordiantor()))
}
