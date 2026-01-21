//
//  PhotoLibraryApp.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 19/01/2026.
//

import SwiftUI

@main
struct PhotoLibraryApp: App {
    @StateObject var coordinator = PhotoLibraryCoordiantor()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                PhotoLibraryView(viewModel: PhotoLibraryViewModel(coordinator: coordinator))
                    .navigationDestination(for: PhotoLibraryRoute.self) { route in
                        coordinator.destinationView(for: route)
                    }
                    .sheet(item: $coordinator.activeModal) { modal in
                        coordinator.modalView(for: modal)
                    }
            }
        }
    }
}
