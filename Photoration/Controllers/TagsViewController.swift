//
//  TagsViewController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/19/21.
//

import UIKit

class TagsViewController: UITableViewController {
    
    var store: PhotoStore!
    var photo: Photo!
    var selectedIndexPaths = [IndexPath]()
    let tagDataSource = TagDataSource()
    var alert = Alert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tagDataSource
        tableView.delegate = self
        updateTags()
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func addNewTag(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textFiled) in
            textFiled.placeholder = "tag name"
            textFiled.autocapitalizationType = .words
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let tagName = alertController.textFields?.first?.text {
                let context = self.store.persistentContainer.viewContext
                let newTag = Tag(context: context)
                newTag.setValue(tagName, forKey: "name")
                try? context.save()
                self.updateTags()
            }
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func updateTags() {
        store.fetchAllTags { (tagsResult) in
            switch tagsResult {
            case let .success(tags):
                self.tagDataSource.tags = tags
                guard let photoTags = self.photo.tags as? Set<Tag> else {
                    return
                }
                
                photoTags.forEach { (tag) in
                    if let index = self.tagDataSource.tags.firstIndex(of: tag) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.selectedIndexPaths.append(indexPath)
                    }
                }
            case .failure:
                self.present(self.alert.alertController(), animated: true, completion: nil)
            }
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}

extension TagsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tagDataSource.tags[indexPath.row]
        if let index = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            photo.removeFromTags(tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addToTags(tag)
        }
        
        try? store.persistentContainer.viewContext.save()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedIndexPaths.firstIndex(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}
