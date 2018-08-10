//
//  ImageGalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Tien Do on 8/9/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
            nameTextField.isEnabled = false
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(canEditTextField))
            doubleTap.numberOfTapsRequired = 2
            self.addGestureRecognizer(doubleTap)
        }
    }
    
    var editCategoryName: String?
    
    @objc func canEditTextField() {
        editCategoryName = nameTextField.text
        nameTextField.isEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        ImageGalleryModel.changeName(editCategoryName!, newCategory: textField.text!)
        nameTextField.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
