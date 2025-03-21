//
//  FlickImageViewController.swift
//  FlickSwift


import UIKit

class FlickImageViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = FlickImageViewModel()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        bindViewModel()
        viewModel.fetchImages()
    }
    
    //MARK: - CustomMethods
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 10, height: 200)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        let nib = UINib(nibName: "FlickImageCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FlickImageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.isLoading = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }
        
        viewModel.onDataUpdate = { [weak self] in
            guard let self = self else { return }  // Safely unwraps self
            if viewModel.numberOfItems == 0 {
                self.collectionView.reloadData()
            } else {
                let startIndex = self.collectionView.numberOfItems(inSection: 0)
                let newIndexPaths = (startIndex..<(startIndex + viewModel.newImageCount)).map { IndexPath(item: $0, section: 0) }
                //For smooth updates
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: newIndexPaths)  //Only insert new items
                }
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        viewModel.fetchImages(reset: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Small delay to ensure safe reload
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
// MARK: - UICollectionView DataSource
extension FlickImageViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickImageCell", for: indexPath) as? FlickImageCell else {return UICollectionViewCell()}
        if let imageModel = viewModel.image(at: indexPath.row) {
            cell.configure(with: imageModel.urls.regular)
        }
        return cell
    }
}
extension FlickImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 {
            viewModel.fetchImages()
        }
    }
}
