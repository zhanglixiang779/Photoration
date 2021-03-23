//
//  ErrorController.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/22/21.
//

import UIKit

struct Alert {
    
    func alertController(title: String = "Alert", message: String = "Something went wrong") -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}
