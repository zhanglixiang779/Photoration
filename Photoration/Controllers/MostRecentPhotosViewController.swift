//
//  MostRecentPhotosViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/20/21.
//

import UIKit

class MostRecentPhotosViewController: PhotosViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotosLocally(category: .mostRecent)
        store.fetchPhotosRemotely(category: .mostRecent) { photosResult in
            if case .success = photosResult {
                self.fetchPhotosLocally(category: .mostRecent)
            }
        }
    }
}
