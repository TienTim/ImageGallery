//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Tien Do on 8/6/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import UIKit

var defaults = UserDefaults.standard

class ImageGalleryTableViewController: UITableViewController {
    
    var category = ""

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ImageGalleryModel.galleries.count
        } else {
            return ImageGalleryModel.deletedGalleries.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! ImageGalleryTableViewCell
        cell.nameTextField.text = indexPath.section == 0 ? ImageGalleryModel.categories[indexPath.row] : ImageGalleryModel.deletedCategories[indexPath.row]
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
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: ImageGalleryModel.deletedCategories.count - 1, section: 1)], with: .none)
                })
            } else {
                let categoryName = ImageGalleryModel.deletedCategories[indexPath.row]
                ImageGalleryModel.delete(categoryName)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let contextualAction = UIContextualAction(style: .normal, title: "Recover") { (action, self, true) in
                let categoryName = ImageGalleryModel.deletedCategories[indexPath.row]
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
        if indexPath.section == 0,
        let cell = tableView.cellForRow(at: indexPath) as? ImageGalleryTableViewCell {
            category = ImageGalleryModel.categories[indexPath.row]
            performSegue(withIdentifier: "ShowCollectionView", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCollectionView" {
            if let nv = segue.destination as? UINavigationController,
                let imageGalleryVC = nv.visibleViewController as? ImageGalleryViewController
            {
                imageGalleryVC.tuples.removeAll()
                imageGalleryVC.title = (sender as? ImageGalleryTableViewCell)?.nameTextField.text ?? ""
                var defaultURLs = [URL]()
                for urlString in imageGalleryVC.defaultURLs {
                    defaultURLs.append(URL(string: urlString)!)
                }
                let imageURLs = defaultURLs + ImageGalleryModel.getGallery(of: category)
                for imageURL in imageURLs {
                    imageGalleryVC.tuples.append((imageURL, 1.0))
                }
            }
        }
    }
    
    //MARK: - View controller lifecycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }

}
