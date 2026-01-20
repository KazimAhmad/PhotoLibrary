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
    var titles: [String] { get set }
    var selectedAlbum: PHAssetCollection? { get set }

    func getThumbnail(asset: PHAsset, size: CGSize) -> UIImage?
    
    func showImage(image: UIImage)
    func goToAlbums()
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
    @Published var titles: [String] = []
    @Published var selectedAlbum: PHAssetCollection?

    private weak var coordinator: PhotoLibraryCoordiantor?

    init(coordinator: PhotoLibraryCoordiantor?) {
        self.coordinator = coordinator
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
        for album in allAlbums {
            titles.append(album.localizedTitle ?? "")
        }
        if customAlbums.count > 0 {
            for index in 0 ... customAlbums.count - 1 {
                let album = customAlbums[index]
                titles.append(album.localizedTitle ?? "")
            }
        }
        print(titles)
        selectedAlbum = allAlbums.first
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
    
    func showImage(image: UIImage) {
        coordinator?.navigate(to: .show(image))
    }
    
    func goToAlbums() {
        coordinator?.present(.albums)
    }
}
