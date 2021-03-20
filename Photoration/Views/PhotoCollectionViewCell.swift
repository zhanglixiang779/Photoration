//
//  PhotoCollectionViewCell.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/18/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var photoDescription: String?
    
    override var isAccessibilityElement: Bool {
        get { true }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get { photoDescription }
        set {  }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return super.accessibilityTraits.union([.image, .button])
        }
        set {  }
    }
    
    func update(displaying image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
