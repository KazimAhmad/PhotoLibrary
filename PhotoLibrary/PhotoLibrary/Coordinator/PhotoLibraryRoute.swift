//
//  OnboardingRoutes.swift
//  Swag
//
//  Created by Kazim Ahmad on 10/01/2026.
//

import Foundation
import Photos
import SwiftUI

public enum PhotoLibraryRoute: Hashable {
    case show(UIImage)
    case selectedImages([PHAsset])
}
