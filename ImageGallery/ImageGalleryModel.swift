//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Tien Do on 8/7/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import Foundation

struct ImageGalleryModel {
    
    static var galleries = [
        "Image Gallery" : ["Apple", "Strawberry", "Kiwi"],
        "Vehicle" : ["Car", "Plane", "Train"]
    ]
    
    static var categories: [String] { return Array(galleries.keys) }
    
    static var deletedGalleries = Dictionary<String, [String]>()
    static var deletedCategories: [String] { return Array(deletedGalleries.keys) }
    
    static let images = [
        "Apple" : "https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201606271147",
        "Strawberry" : "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/PerfectStrawberry.jpg/220px-PerfectStrawberry.jpg",
        "Kiwi" : "https://i.ytimg.com/vi/DwkMkTKHPm8/maxresdefault.jpg",
        "Car" : "https://www.verzekerdbijhema-cdn.nl/assets/images/transparant/210x210/AUTO.png",
        "Plane" : "https://heavyeditorial.files.wordpress.com/2018/07/plane-ract1.jpg?quality=65&strip=all",
        "Train" : "https://www.seat61.com/images/Aust-prospector-train-ext.jpg"
    ]
    
    static func getGallery(of category: String) -> [URL] {
        var urls = [URL]()
        if galleries.keys.contains(category) {
            for imageName in galleries[category]! {
                if images.keys.contains(imageName) {
                    urls.append(URL(string: images[imageName]!)!)
                }
            }
        }
        return urls
    }
    
    static func moveToTrash(_ category: String) {
        if let index = galleries.index(forKey: category) {
            let gallery = galleries.remove(at: index)
            deletedGalleries[gallery.key] = gallery.value
        }
    }
    
    static func delete(_ category: String) {
        if let index = deletedGalleries.index(forKey: category) {
            deletedGalleries.remove(at: index)
        }
    }
    
    static func recover(_ category: String) {
        if let index = deletedGalleries.index(forKey: category) {
            let gallery = deletedGalleries.remove(at: index)
            galleries[gallery.key] = gallery.value
        }
    }
    
    static func changeName(_ category: String, newCategory: String) {
        if let index = galleries.index(forKey: category) {
            let gallery = galleries.remove(at: index)
            galleries[newCategory] = gallery.value
        }
    }
    
}
