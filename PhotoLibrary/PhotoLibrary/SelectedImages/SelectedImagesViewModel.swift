//
//  SelectedImagesViewModel.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 21/01/2026.
//

import Foundation
import Photos
import SwiftUI

enum JPEGQuality: CGFloat {
    case lowest = 0
    case low = 0.25
    case medium = 0.5
    case high = 0.75
    case highest = 1
}

class SelectedImagesViewModel: ObservableObject {
    let selectedImages: [PHAsset]
    let coordinator: PhotoLibraryCoordiantor
    
    init(selectedImages: [PHAsset],
         coordinator: PhotoLibraryCoordiantor) {
        self.selectedImages = selectedImages
        self.coordinator = coordinator
    }
    
    func getImage(asset: PHAsset, size: CGSize) -> UIImage? {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        var imageToReturn: UIImage?
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, info) in
            guard let image = image else {
                return
            }
            imageToReturn = image
        }
        return imageToReturn
    }
    
    func getCompressedData(asset: PHAsset) -> Data? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.version = .original
        
        var imageData: Data?
        let imageManager = PHImageManager.default()
        imageManager.requestImageDataAndOrientation(for: asset,
                                                    options: options) { (data, str, orientation, options) in
            imageData = data
        }
        let _ = getResisedImage(from: imageData)
        return imageData
    }
    
    func getResisedImage(from data: Data?,
                         quality: JPEGQuality = .highest) -> UIImage? {
        guard let data, let image = UIImage(data: data) else { return nil }
        if let imageData = image.jpegData(compressionQuality: quality.rawValue) {
            let resizedImage = UIImage(data: imageData)
            return resizedImage
        }
        return nil
    }
}
