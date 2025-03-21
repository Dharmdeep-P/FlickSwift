//
//  APIError.swift
//  FlickSwift

import Foundation

enum APIError: Error {
    case noInternet
    case invalidURL
    case requestFailed(String)
    case decodingFailed(String)
    case mockAPIFailed

    var localizedDescription: String {
        switch self {
        case .noInternet:
            return "No Internet Connection. Please check your network and try again."
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        case .mockAPIFailed:
            return "Mock API Failed"
        }
    }
}
