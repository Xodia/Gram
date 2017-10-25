//
//  GramViewController.swift
//  Gram
//
//  Created by Morgan Collino on 10/25/17.
//  Copyright © 2017 Morgan Collino. All rights reserved.
//

import UIKit

/// Gram view controller.
class GramViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var gramImageView: UIImageView!
    @IBOutlet private weak var filterCollectionView: UICollectionView!
    @IBOutlet private weak var selectImageButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!

    // MARK: - Private propeties
    private let filters: [GramFilter] = [
        NormalFilter(),
        MosaicFilter(),
        LaMuseFilter(),
        CandyFilter(),
        UdnieFilter(),
        TheScreamFilter()
    ]
    
    private var renderedFilterBuffer: [String: ImageBuffer] = [:]
    private var imageBuffer: ImageBuffer?
    private var selectedIndex: Int = 0
    
    // MARK: - Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = gramImageView.image {
            let resizedImage = image.resize(to: CGSize(width: 720, height: 720))
            gramImageView.image = resizedImage
            imageBuffer = resizedImage.buffer()
            loadRenderedImages()
        }
    }
    
    // MARK: - Private functions
    private func loadRenderedImages() {
        renderedFilterBuffer.removeAll()
        guard let buffer = imageBuffer else {
            return
        }
        
        filters.forEach { (filter) in
            if let filteredBuffer = filter.render(from: buffer) {
                renderedFilterBuffer[filter.name] = filteredBuffer
            }
        }

        filterCollectionView.reloadData()
    }
    
    private func updateImageView() {
        guard let imageBuffer = imageBuffer else {
            return
        }
        
        let image = UIImage(imageBuffer: imageBuffer)
        gramImageView.image = image
    }
    
    // MARK: - IBActions
    @IBAction private func selectImageButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped() {
        guard let image = gramImageView.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}

// MARK: - UINavigationControllerDelegate
extension GramViewController: UINavigationControllerDelegate {
    
}

// MARK: - UIImagePickerControllerDelegate
extension GramViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the chosen image.
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let selectedImage = chosenImage.smartCrop().resize(to: CGSize(width: 720, height: 720))
            imageBuffer = selectedImage.buffer()
            gramImageView.image = selectedImage
            loadRenderedImages()
            filterCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDataSource
extension GramViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GramFilterCollectionViewCell", for: indexPath) as! GramFilterCollectionViewCell
        cell.isSelected = selectedIndex == indexPath.row

        let filter = filters[indexPath.row]
        if let buffer = renderedFilterBuffer[filter.name] {
            cell.setup(with: filter, imageBuffer: buffer)
        }

        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension GramViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GramFilterCollectionViewCell

        // Scroll to item selected.
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // Deselect old item if there was one.
        deselectOldItem(collectionView: collectionView)
        // Set current selected.
        cell.isSelected = true
        // Save index of selected item.
        selectedIndex = indexPath.row

        let filter = filters[indexPath.row]
        if let buffer = renderedFilterBuffer[filter.name] {
            imageBuffer = buffer
        }
        updateImageView()
    }
    
    func deselectOldItem(collectionView: UICollectionView) {
        if let itemsSelected = collectionView.indexPathsForSelectedItems?.first {
            let previouslySelectedCell = collectionView.cellForItem(at: itemsSelected)
            previouslySelectedCell?.isSelected = false
        }
    }
    
}
