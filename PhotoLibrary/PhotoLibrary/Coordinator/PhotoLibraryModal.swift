//
//  OnboardingModal.swift
//  Swag
//
//  Created by Kazim Ahmad on 10/01/2026.
//

import Foundation

enum PhotoLibraryModal: Identifiable {
    case albums([String], ((String) -> Void))
    var id: String {
        switch self {
        case .albums:
            "albums"
        }
    }
}
