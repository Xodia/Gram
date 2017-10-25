//
//  GramFilter.swift
//  Gram
//
//  Created by Morgan Collino on 10/25/17.
//  Copyright © 2017 Morgan Collino. All rights reserved.
//

import Foundation
import UIKit

/// Gram Filter.
protocol GramFilter {
    
    /// Filter name.
    var name: String { get }
    
    /// Render - Feed the ML model with the given ImageBuffer and get the output of it.
    ///
    /// - Parameter from: Given image buffer (input) to the ML Model.
    /// - Returns: Output image buffer from the ML Model.
    func render(from: ImageBuffer) -> ImageBuffer?
    
}

/// Normal filter.
class NormalFilter: GramFilter {
    
    let name: String = "Normal"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        return from
    }
    
}

/// Mosaic filter.
class MosaicFilter: GramFilter {
    
    let name: String = "Mosaic"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        let model = FNSMosaic()
        let prediction = try? model.prediction(inputImage: from)
        
        return prediction?.outputImage
    }
    
}

/// La Muse filter.
class LaMuseFilter: GramFilter {
    
    let name: String = "La Muse"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        let model = FNSLaMuse()
        let prediction = try? model.prediction(inputImage: from)
        
        return prediction?.outputImage
    }
}

/// The Scream filter.
class TheScreamFilter: GramFilter {
    
    let name: String = "The Scream"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        let model = FNSTheScream()
        let prediction = try? model.prediction(inputImage: from)
        
        return prediction?.outputImage
    }
}

/// Candy filter.
class CandyFilter: GramFilter {
    
    let name: String = "Candy"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        let model = FNSCandy()
        let prediction = try? model.prediction(inputImage: from)
        
        return prediction?.outputImage
    }
}

/// Udnie filter.
class UdnieFilter: GramFilter {
    
    let name: String = "Udnie"
    
    func render(from: ImageBuffer) -> ImageBuffer? {
        let model = FNSUdnie()
        let prediction = try? model.prediction(inputImage: from)
        
        return prediction?.outputImage
    }
}
