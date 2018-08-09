//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Tien Do on 8/6/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    var imageURLs = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ImageGalleryModel.gallery.count
        } else {
            return ImageGalleryModel.recentlyDeleted.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! ImageGalleryTableViewCell
        cell.nameTextField.text = indexPath.section == 0 ? ImageGalleryModel.categories[indexPath.row] : ImageGalleryModel.categoriesOfTrash[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Recently Deleted" : nil
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let categoryName = ImageGalleryModel.categories[indexPath.row]
                ImageGalleryModel.moveToTrash(categoryName)
                tableView.moveRow(at: indexPath, to: IndexPath(row: ImageGalleryModel.categoriesOfTrash.count - 1, section: 1))
            } else {
                let categoryName = ImageGalleryModel.categoriesOfTrash[indexPath.row]
                ImageGalleryModel.delete(categoryName)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let contextualAction = UIContextualAction(style: .normal, title: "Recover") { (action, self, true) in
                let categoryName = ImageGalleryModel.categoriesOfTrash[indexPath.row]
                ImageGalleryModel.recover(categoryName)
                tableView.reloadData()
            }
            return UISwipeActionsConfiguration(actions: [contextualAction])
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let categoryName = ImageGalleryModel.categories[indexPath.row]
            imageURLs = ImageGalleryModel.getCategory(of: categoryName)
            performSegue(withIdentifier: "ShowCollectionView", sender: self)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCollectionView" {
            if let nv = segue.destination as? UINavigationController,
                let imageGalleryVC = nv.visibleViewController as? ImageGalleryViewController
            {
                imageGalleryVC.tuples.removeAll()
                for imageURL in imageURLs {
                    imageGalleryVC.tuples.append((imageURL, 1.0))
                }
            }
        }
    }

}
