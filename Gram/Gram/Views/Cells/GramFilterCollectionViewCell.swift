//
//  GramFilterCollectionViewCell.swift
//  Gram
//
//  Created by Morgan Collino on 10/25/17.
//  Copyright © 2017 Morgan Collino. All rights reserved.
//

import UIKit

/// Gram filter collecgtion view cell.
class GramFilterCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var filterImageView: UIImageView!
    
    // MARK: - Overriden function
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // animate selection
                nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            } else {
                // animate deselection
                nameLabel.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }
    
    // MARK: - Public functions
    /// Setup collection view cell with given filter and image buffer.
    ///
    /// - Parameters:
    ///   - filter: Filter.
    ///   - imageBuffer: Image buffer used to showed a preview of the filter work.
    func setup(with filter: GramFilter, imageBuffer: ImageBuffer) {
        nameLabel.text = filter.name
        filterImageView.image = UIImage(imageBuffer: imageBuffer)
    }
    
}
