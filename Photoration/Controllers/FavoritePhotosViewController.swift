//
//  FavoritePhotosViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/21/21.
//

import UIKit

class FavoritePhotosViewController: PhotosViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.refreshControl = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPhotosLocally()
    }
    
    override func fetchPhotosLocally() {
        store.fetchFavoritePhotos { (photosResult) in
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension FavoritePhotosViewController {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = flowLayout?.minimumInteritemSpacing ?? 0.0
        let size: CGFloat = (collectionView.frame.size.width - 3 * space) / 2.0
            return CGSize(width: size, height: size)
        }
}
