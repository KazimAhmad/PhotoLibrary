//
//  PhotoLibraryApp.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 19/01/2026.
//

import SwiftUI

@main
struct PhotoLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoLibraryView(viewModel: PhotoLibraryViewModel())
        }
    }
}
