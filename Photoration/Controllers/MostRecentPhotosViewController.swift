//
//  MostRecentPhotosViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/20/21.
//

import UIKit

class MostRecentPhotosViewController: PhotosViewController {
    
    private let refreshControl = UIRefreshControl()
    
    override var category: PhotoCategory {
        return .mostRecent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControll()
    }
    
    private func setupRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refetchPhotos), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching photos ...")
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refetchPhotos() {
        store.fetchPhotosRemotely(category: category) { photosResult in
            if case .success = photosResult {
                self.fetchPhotosLocally()
            }
            
            self.refreshControl.endRefreshing()
        }
    }
}
