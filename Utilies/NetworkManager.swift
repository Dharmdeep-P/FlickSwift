//
//  NetworkManager.swift
//  FlickSwift

import Foundation
import Network

protocol NetworkService {
    func fetchImages(page: Int, perPage: Int, completion: @escaping (Result<[FlickImageModel], APIError>) -> Void)
}

final class NetworkManager:NetworkService {
    static let shared = NetworkManager()
    private let accessKey = "XBhytmm18SjZPUT0JBcRboCjLglE1HZPHkf2_GNul64"
    private let baseURL = "https://api.unsplash.com/photos"
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var currentStatus: NWPath.Status = .requiresConnection

    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.currentStatus = path.status
        }
        monitor.start(queue: queue)
    }
    
    // Ensures `NWPathMonitor` is updated before returning network status
    private func isConnected(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) { // Small delay to allow update
            completion(self.currentStatus == .satisfied)
        }
    }
    
    func fetchImages(page: Int, perPage: Int, completion: @escaping (Result<[FlickImageModel], APIError>) -> Void) {
        let urlString = "\(baseURL)?client_id=\(accessKey)&page=\(page)&per_page=\(perPage)"
        
        isConnected { isConnected in
            guard isConnected else {
                completion(.failure(.noInternet))
                return
            }
            
            guard let url = URL(string: urlString) else {
                completion(.failure(.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(.requestFailed(error?.localizedDescription ?? "Unknown error")))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode([FlickImageModel].self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingFailed(error.localizedDescription)))
                }
            }
            
            task.resume()
        }
    }
}
