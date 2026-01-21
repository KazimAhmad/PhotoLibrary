//
//  OnboardingCoordiantor.swift
//  Swag
//
//  Created by Kazim Ahmad on 10/01/2026.
//

import Foundation
import SwiftUI

protocol PhotoLibraryCoordiantorProtocol {
    func navigate(to destination: PhotoLibraryRoute)
    func present(_ modal: PhotoLibraryModal)
    func pop()
    func dismissModal()
}

class PhotoLibraryCoordiantor: ObservableObject, PhotoLibraryCoordiantorProtocol {
    @Published var path = NavigationPath()
    @Published var activeModal: PhotoLibraryModal? = nil

    func navigate(to destination: PhotoLibraryRoute) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    // MARK: - Modals
    func present(_ modal: PhotoLibraryModal) {
        activeModal = modal
    }
    
    func dismissModal() {
        activeModal = nil
    }
    
    // MARK: - View Builders
    @MainActor @ViewBuilder
    func destinationView(for destination: PhotoLibraryRoute) -> some View {
        switch destination {
            case .show(let image):
            Image(uiImage: image)
                .resizable()
            case .selectedImages(let images):
            SelectedImagesView(viewModel: SelectedImagesViewModel(selectedImages: images,
                                                                  coordinator: self))
        }
    }
}

extension PhotoLibraryCoordiantor {
    @ViewBuilder
    func modalView(for modal: PhotoLibraryModal) -> some View {
        switch modal {
        case .albums(let titles, let didSelectAlbum):
            AlbumsView(viewModel: AlbumsViewModel(titles: titles,
                                                  didSelectAlbum: didSelectAlbum,
                                                  coordinator: self))
            .background(
                ClearBackgroundView()
            )
        }
    }
}
