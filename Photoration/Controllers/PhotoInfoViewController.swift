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
    
    var store: PhotoStore!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
            let updatedPhoto = store.persistentContainer.viewContext.object(with: photo.objectID) as! Photo
            photo.isFavorite = updatedPhoto.isFavorite
        }
    }
    
    var buttonState: State {
        if photo.isFavorite {
            return .delete
        } else {
            return .save
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
                print("Error fetching image for photo: \(error)")
            }
        }
        
        initActionButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags":
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            tagController.photo = photo
            tagController.store = store
        default:
            preconditionFailure("Unexpected segue identifier")
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
            try store.persistentContainer.viewContext.save()
        } catch {
            photo.isFavorite = false
            print("Error saving image for photo: \(error)")
        }
        actionButton.title = buttonState.rawValue
    }
    
    private func unfavPhoto() {
        do {
            photo.isFavorite = false
            try store.persistentContainer.viewContext.save()
        } catch {
            photo.isFavorite = true
            print("Error deleting image for photo: \(error)")
        }
        actionButton.title = buttonState.rawValue
    }
}
