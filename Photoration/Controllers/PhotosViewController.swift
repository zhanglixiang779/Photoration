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
    let photoDataSource = PhotoDataSource()
    private let refreshControl = UIRefreshControl()
    private let alert = Alert()

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
        store.viewContext.automaticallyMergesChangesFromParent = true
        store.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func cellSize(layout collectionViewLayout: UICollectionViewLayout, numOfCell number: CGFloat) -> CGSize {
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = flowLayout?.minimumInteritemSpacing ?? 0.0
        let size: CGFloat = (collectionView.frame.size.width - (number + 1) * space) / number
            return CGSize(width: size, height: size)
    }
    
    private func fetchPhotosRemotely() {
        if let category = category {
            store.fetchPhotosRemotely(category: category) { photosResult in
                switch photosResult {
                case .success:
                    self.fetchPhotosLocally()
                case let .failure(error):
                    self.present(self.alert.alertController(message: error.localizedDescription), animated: false, completion: nil)
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.bounds.size.height), animated: true)
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
        cellSize(layout: collectionViewLayout, numOfCell: 4.0)
    }
}

