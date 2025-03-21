//
//  FlickImageViewModel.swift
//  FlickSwift

import Foundation

final class FlickImageViewModel {
    
    private let networkService: NetworkService // Injected dependency
    private var currentPage = 1
    private let perPage = 20 // Number of images per API call
    private var isFetching = false

    
    var images: [FlickImageModel] = []
    var isLoading: ((Bool) -> Void)? // Callback for loading state
    var onDataUpdate: (() -> Void)? // Callback for UI updates
    var onError: ((String) -> Void)?
    
    
    // Dependency Injection (Default: NetworkManager.shared)
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    var numberOfItems: Int {
        return images.count
    }

    var newImageCount: Int = 0
    
    func image(at index: Int) -> FlickImageModel? {
        return images.count > 0 ? images[index] : nil
    }

    func fetchImages(reset:Bool = false) {
        if isFetching { return } // Prevent duplicate API calls
        isFetching = true
        
        
        if reset {
            ImageCacheManager.shared.clearCache()
            images.removeAll()
            currentPage = 1
            self.onDataUpdate?() // Notify UI to reload
        } else {
            isLoading?(true) // Show loader
        }
        
        networkService.fetchImages(page: currentPage, perPage: perPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading?(false) // Hide loader
                self?.isFetching = false
                
                switch result {
                case .success(let images):
                    self?.newImageCount = images.count
                    self?.images.append(contentsOf: images)
                    self?.onDataUpdate?() // Notify UI to reload
                    self?.currentPage += 1
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}

