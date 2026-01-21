//
//  PhotoLibraryViewModel.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 19/01/2026.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI

protocol PhotoLibraryViewModelProtocol: ObservableObject {
    var viewState: ViewState { get set }
    var authorizationStatus: PHAuthorizationStatus { get set }
    var photosInRecentAlbum: PHFetchResultCollection { get set }
    var allAlbums: [PHAssetCollection] { get set }
    var customAlbums: PHFetchResult<PHAssetCollection> { get set }
    var fetchedAlbumTypes: [PHAssetCollectionSubtype] { get set }

    var titles: [String] { get set }
    var selectedAlbum: PHAssetCollection? { get set }

    var selection: Bool { get set }
    var selectedImages: [PHAsset] { get set }
    func imageSelection(for photo: PHAsset)
    func isSelected(photo: PHAsset) -> Bool

    func getPhotosPermission()
    func getPhotosLibraries()

    func getThumbnail(asset: PHAsset, size: CGSize) -> UIImage?
    func updatePictures()
    
    func showImage(image: UIImage)
    func goToAlbums()
    
    func openSettings()
    func goToSelectedImages()
}

class PhotoLibraryViewModel: PhotoLibraryViewModelProtocol {
    var viewState: ViewState = .info
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
    @Published var selection: Bool = false
    @Published var selectedImages: [PHAsset] = []
    
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
                } else {
                    self?.viewState = .error
                }
            }
        }
    }
    
    func getPhotosLibraries() {
        if allAlbums.count > 0 { return }
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
        selectedAlbum = allAlbums.first
        viewState = .info
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
    
    func updatePictures() {
        guard let selectedAlbum = selectedAlbum else {
            return
        }
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        let fetchedAssets = PHAsset.fetchAssets(in: selectedAlbum, options: fetchOptions)
        photosInRecentAlbum = PHFetchResultCollection(fetchResult: fetchedAssets)
    }
    
    func imageSelection(for photo: PHAsset) {
        if selectedImages.first(where: { $0.localIdentifier == photo.localIdentifier }) == nil {
            selectedImages.append(photo)
        } else {
            selectedImages.removeAll() { $0.localIdentifier == photo.localIdentifier }
        }
    }
    
    func isSelected(photo: PHAsset) -> Bool {
        return selectedImages.first(where: { $0.localIdentifier == photo.localIdentifier }) != nil
    }
}

extension PhotoLibraryViewModel {
    
    func goToAlbums() {
        coordinator?.present(.albums(titles, { [weak self] selectedTitle in
            guard let self = self else {
                return
            }
            if let albumFromAll = self.allAlbums.first(where: { $0.localizedTitle == selectedTitle }) {
                self.selectedAlbum = albumFromAll
                return
            }
            if customAlbums.count > 0 {
                for index in 0 ... customAlbums.count - 1 {
                    let albumTitle = customAlbums[index].localizedTitle
                    if albumTitle == selectedTitle {
                        self.selectedAlbum = customAlbums[index]
                        return
                    }
                }
            }
        }))
    }
    
    func showImage(image: UIImage) {
        coordinator?.navigate(to: .show(image))
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: "App-prefs:com.app.PhotoLibrary") else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                
            })
        }
    }
    
    func goToSelectedImages() {
        coordinator?.navigate(to: .selectedImages(selectedImages))
    }
}
