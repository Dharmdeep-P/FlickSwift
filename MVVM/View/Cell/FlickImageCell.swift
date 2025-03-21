//
//  FlickImageCell.swift
//  FlickSwift


import UIKit

class FlickImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with urlString: String) {
        
        ImageCacheManager.shared.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                //if image is nil,keep placeholder image
                if let downloadedImage = image {
                    self?.imageView.image = downloadedImage
                }
            }
        }
    }
}
