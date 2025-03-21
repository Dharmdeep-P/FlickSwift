//
//  ImageCacheManager.swift
//  FlickSwift

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    
    // Public method to test storing an image
    #if DEBUG
    func storeImageForTesting(_ image: UIImage, forKey key: String) {
        self.setImage(image, forKey: key)
        
    }
    #endif
    
    // Get image from cache
    private func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    // Save image to cache
    private func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    // Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if image exists in cache
        if let cachedImage = self.getImage(forKey: urlString) {
            completion(cachedImage)
            return  // Early return to avoid unnecessary processing
        }
        
        guard let url = URL(string: urlString) else {
            debugPrint("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let downloadedImage = UIImage(data: data) else {
                debugPrint("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // Save image to cache
            self.setImage(downloadedImage, forKey: urlString)

            DispatchQueue.main.async {
                completion(downloadedImage)
                
            }
            
        }.resume()

    }
}

