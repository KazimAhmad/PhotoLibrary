//
//  PhotoLibraryViewModel.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 19/01/2026.
//

import Foundation
import Photos
import SwiftUI

protocol PhotoLibraryViewModelProtocol: ObservableObject {
    var authorizationStatus: PHAuthorizationStatus { get set }
    var photosInRecentAlbum: PHFetchResultCollection { get set }
    var allAlbums: [PHAssetCollection] { get set }
    var customAlbums: PHFetchResult<PHAssetCollection> { get set }
    var fetchedAlbumTypes: [PHAssetCollectionSubtype] { get set }

    func getPhotosPermission()
    func getPhotosLibraries()
    func getThumbnail(asset: PHAsset, size: CGSize) -> UIImage?
}

class PhotoLibraryViewModel: PhotoLibraryViewModelProtocol {
    @Published var authorizationStatus = PHAuthorizationStatus.notDetermined

    @Published var photosInRecentAlbum: PHFetchResultCollection = .init(fetchResult: .init())
    @Published var allAlbums: [PHAssetCollection] = []
    @Published var customAlbums: PHFetchResult<PHAssetCollection> = .init()
    @Published var fetchedAlbumTypes: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary,
                                                                    .smartAlbumFavorites,
                                                                    .smartAlbumScreenshots,
                                                                    .smartAlbumVideos,
                                                                    .smartAlbumSlomoVideos]
    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    func getPhotosPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async { [weak self] in
                self?.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self?.getPhotosLibraries()
                }
            }
        }
    }
    
    func getPhotosLibraries() {        
        for fetchedAlbumType in fetchedAlbumTypes {
            if let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: fetchedAlbumType, options: nil).firstObject {
                allAlbums.append(album)
            }
        }
        
        let customAlbumsOptions: PHFetchOptions = .init()
        customAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: customAlbumsOptions)
        
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        photosInRecentAlbum = PHFetchResultCollection(fetchResult: PHAsset.fetchAssets(with: fetchOptions))
    }
    
    func getThumbnail(asset: PHAsset, size: CGSize) -> UIImage? {
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
}

struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    var endIndex: Int { fetchResult.count }
    var startIndex: Int { 0 }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: fetchResult.count - position - 1)
    }
}

