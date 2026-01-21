//
//  AlbumsViewModel.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 20/01/2026.
//

import Foundation

class AlbumsViewModel: ObservableObject {
    @Published var titles: [String]
    var didSelectAlbum: ((String) -> Void)?
    var coordinator: PhotoLibraryCoordiantor
    
    init(titles: [String],
         didSelectAlbum: ((String) -> Void)? = nil,
         coordinator: PhotoLibraryCoordiantor) {
        self.titles = titles
        self.didSelectAlbum = didSelectAlbum
        self.coordinator = coordinator
    }
    
    func dismiss() {
        coordinator.dismissModal()
    }
}
