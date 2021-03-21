//
//  InterestingPhotosViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/20/21.
//

import UIKit

class InterestingPhotosViewController: PhotosViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotosLocally(category: .interesting)
        store.fetchPhotosRemotely(category: .interesting) { photosResult in
            if case .success = photosResult {
                self.fetchPhotosLocally(category: .interesting)
            }
        }
    }
}
