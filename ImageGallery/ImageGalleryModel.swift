//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Tien Do on 8/7/18.
//  Copyright © 2018 tiendo. All rights reserved.
//

import Foundation

struct ImageGalleryModel {
    
    static var gallery = [
        "Food" : ["Apple", "Strawberry", "Kiwi"],
        "Vehicle" : ["Car", "Plane", "Train"]
    ]
    
    static var categories: [String] { return Array(gallery.keys) }
    
    static var recentlyDeleted = Dictionary<String, [String]>()
    static var categoriesOfTrash: [String] { return Array(recentlyDeleted.keys) }
    
    static let images = [
        "Apple" : "https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201606271147",
        "Strawberry" : "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/PerfectStrawberry.jpg/220px-PerfectStrawberry.jpg",
        "Kiwi" : "https://i.ytimg.com/vi/DwkMkTKHPm8/maxresdefault.jpg",
        "Car" : "https://www.verzekerdbijhema-cdn.nl/assets/images/transparant/210x210/AUTO.png",
        "Plane" : "https://heavyeditorial.files.wordpress.com/2018/07/plane-ract1.jpg?quality=65&strip=all",
        "Train" : "https://www.seat61.com/images/Aust-prospector-train-ext.jpg"
    ]
    
    static func getCategory(of name: String) -> [URL] {
        var urls = [URL]()
        if gallery.keys.contains(name) {
            for imageName in gallery[name]! {
                if images.keys.contains(imageName) {
                    urls.append(URL(string: images[imageName]!)!)
                }
            }
        }
        return urls
    }
    
    static func moveToTrash(_ categoryName: String) {
        if let index = gallery.index(forKey: categoryName) {
            let category = gallery.remove(at: index)
            recentlyDeleted[category.key] = category.value
        }
    }
    
    static func delete(_ categoryName: String) {
        if let index = recentlyDeleted.index(forKey: categoryName) {
            recentlyDeleted.remove(at: index)
        }
    }
    
    static func recover(_ categoryName: String) {
        if let index = recentlyDeleted.index(forKey: categoryName) {
            let category = recentlyDeleted.remove(at: index)
            gallery[category.key] = category.value
        }
    }
    
    static func changeName(_ categoryName: String, newName: String) {
        if let index = gallery.index(forKey: categoryName) {
            let category = gallery.remove(at: index)
            gallery[newName] = category.value
        }
    }
    
}
