//
//  PhotoInfoViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/18/21.
//

import UIKit
import CoreData

enum State: String {
    case save = "Save"
    case delete = "Delete"
}

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    private let alert = Alert()
    
    private var buttonState: State {
        if photo.isFavorite {
            return .delete
        } else {
            return .save
        }
    }
    
    var store: PhotoStore!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
            let updatedPhoto = store.viewContext.object(with: photo.objectID) as! Photo
            photo.isFavorite = updatedPhoto.isFavorite
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        imageView.accessibilityLabel = photo.title
        store.fetchImage(for: photo) { (result) in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                self.present(self.alert.alertController(message: error.localizedDescription), animated: true, completion: nil)
            }
        }
        
        initActionButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTags" {
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            tagController.photo = photo
            tagController.store = store
        }
    }
    
    @IBAction func toggle(_ sender: UIBarButtonItem) {
        switch buttonState {
        case .save:
            favPhoto()
        case.delete:
            unfavPhoto()
        }
    }
    
    private func initActionButton() {
        actionButton.title = buttonState.rawValue
    }
    
    private func favPhoto() {
        do {
            photo.isFavorite = true
            try store.viewContext.save()
        } catch {
            photo.isFavorite = false
            present(alert.alertController(message: "Cannot save image, please try again!"), animated: true, completion: nil)
        }
        actionButton.title = buttonState.rawValue
    }
    
    private func unfavPhoto() {
        do {
            photo.isFavorite = false
            try store.viewContext.save()
        } catch {
            photo.isFavorite = true
            present(alert.alertController(message: "Cannot unfavorite image, please try again!"), animated: true, completion: nil)
        }
        actionButton.title = buttonState.rawValue
    }
}
