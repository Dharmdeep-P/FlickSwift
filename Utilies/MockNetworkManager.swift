//
//  MockNetworkManager.swift
//  FlickSwift

import Foundation
class MockNetworkManager: NetworkService {
    
    var shouldReturnError = false
    var mockData: Data?

    func fetchImages(page: Int, perPage: Int, completion: @escaping (Result<[FlickImageModel], APIError>) -> Void) {
        
        if shouldReturnError {
            completion(.failure(.mockAPIFailed))
        }
        
        guard let data = mockData else {
            completion(.failure(.requestFailed("No Mock Data found")))
            return
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode([FlickImageModel].self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(.decodingFailed(error.localizedDescription)))
        }

    }

}

