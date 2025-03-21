//
//  FlickImageModel.swift
//  FlickSwift
//
//  Created by Dharmdeep Poojara on 20/03/25.
//

import Foundation

struct FlickImageModel: Decodable {
    let id: String
    let urls: ImageURLs
}

struct ImageURLs: Decodable {
    let regular: String
}
