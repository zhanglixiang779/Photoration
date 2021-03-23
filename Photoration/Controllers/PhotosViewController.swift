//
//  ViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/14/21.
//

import UIKit
import CoreData

/**
 This is the Base ViewController for
 1: InterestingPhotosViewController
 2: MostRecentPhotosViewController
 */
class PhotosViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var category: PhotoCategory? {
        return nil
    }
    
    var store: PhotoStore!
    let refreshControl = UIRefreshControl()
    let photoDataSource = PhotoDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        setupRefreshControll()
        configureContexts()
        fetchPhotosLocally()
        fetchPhotosRemotely()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.store = store
                destinationVC.photo = photo
            }
        }
    }
    
    func fetchPhotosLocally() {
        if let category = category {
            store.fetchPhotosLocally(category: category) { (photosResult) in
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
    
    func configureContexts() {
        store.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        store.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    private func fetchPhotosRemotely() {
        if let category = category {
            store.fetchPhotosRemotely(category: category) { photosResult in
                if case .success = photosResult {
                    self.fetchPhotosLocally()
                }
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refetchPhotos), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching photos ...")
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refetchPhotos() {
        fetchPhotosRemotely()
    }
}

// MARK: UICollectionViewDelegate

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        store.fetchImage(for: photo) { (result) in
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                  case let .success(image) = result else {
                return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(displaying: image)
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = flowLayout?.minimumInteritemSpacing ?? 0.0
        let size: CGFloat = (collectionView.frame.size.width - 5 * space) / 4.0
            return CGSize(width: size, height: size)
        }
}

