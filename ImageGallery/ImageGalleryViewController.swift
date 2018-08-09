//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Tien Do on 8/7/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDropDelegate, UICollectionViewDragDelegate, UIDropInteractionDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    var tuples = [(imageURL: URL, imageRatio: CGFloat)]()
    
    var cellWidthScale: CGFloat = 1  {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }

    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(adjustCellWidth(byHandlingGestureRecognizedBy:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func adjustCellWidth(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            cellWidthScale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }    

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tuples.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! ImageGalleryCollectionViewCell
        cell.spinner.startAnimating()
        let tuple = tuples[indexPath.item]
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: tuple.imageURL) {
                DispatchQueue.main.async {
                    cell.spinner.stopAnimating()
                    let image = UIImage(data: data)
                    cell.imageView.image = image
                    if tuple.imageRatio == 1.0 {
                        self.tuples[indexPath.item].imageRatio = image!.size.height / image!.size.width
                    }
                    cell.url = tuple.imageURL
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (_, ratio) = tuples[indexPath.item]
        return CGSize(width: 120 * cellWidthScale, height: ratio * 120 * cellWidthScale)
    }
    
    //MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let url = (collectionView?.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.url {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: url as NSItemProviderWriting))
            dragItem.localObject = url
            return [dragItem]
        } else {
            return []
        }
    }
    
    //MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let _ = item.dragItem.localObject as? URL {
                    collectionView.performBatchUpdates({
                        let tuple = tuples.remove(at: sourceIndexPath.item)
                        tuples.insert(tuple, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceHolderCell")
                )
                var ratio: CGFloat = 0
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let image = provider as? UIImage {
                        ratio = image.size.height / image.size.width
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            let imageURL = url.imageURL
                            placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.tuples.insert((imageURL, ratio), at: insertionIndexPath.item)
                            })
                            self.collectionView.reloadData()
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
}
