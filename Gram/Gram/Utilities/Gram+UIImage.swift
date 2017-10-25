//
//  Gram+UIImage.swift
//  Gram
//
//  Created by Morgan Collino on 10/25/17.
//  Copyright © 2017 Morgan Collino. All rights reserved.
//

import UIKit
import VideoToolbox

/// Image buffer.
typealias ImageBuffer = CVPixelBuffer

// MARK: - UIImage extension.
extension UIImage {
    
    // MARK: - Init/Deinit functions
    convenience init?(imageBuffer: ImageBuffer) {
        var cgImage: CGImage?
        
        VTCreateCGImageFromCVPixelBuffer(imageBuffer, nil, &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    
    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    
    /// Crop image with given rectangle frame.
    ///
    /// - Parameter rect: Rectangle zone taken from the original image.
    /// - Returns: Cropped image.
    func crop(to rect: CGRect) -> UIImage {
        if let imageRef: CGImage = self.cgImage?.cropping(to: rect) {
            let cropped: UIImage = UIImage(cgImage: imageRef, scale: 0, orientation: self.imageOrientation)
            return cropped
        }
        return self
    }
    
    /// Square up the image and centerising the cropping.
    ///
    /// - Returns: Cropped image.
    func smartCrop() -> UIImage {
        var imageHeight = self.size.height
        var imageWidth = self.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        guard let width = self.cgImage?.width, let height = self.cgImage?.height else {
            return self
        }
        
        let refWidth: CGFloat = CGFloat(width)
        let refHeight: CGFloat = CGFloat(height)
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        return crop(to: cropRect)
    }
    
    /// Transforming the UIImage into a CVPixelBuffer (ImageBuffer).
    ///
    /// - Returns: Image buffer representation of the UIImage.
    func buffer() -> ImageBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}
