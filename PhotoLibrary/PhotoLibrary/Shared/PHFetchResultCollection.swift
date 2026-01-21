//
//  PHFetchResultCollection.swift
//  PhotoLibrary
//
//  Created by Kazim Ahmad on 20/01/2026.
//

import Foundation
import Photos

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
