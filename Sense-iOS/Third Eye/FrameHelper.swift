//
//  VisionHelper.swift
//  Third Eye
//
//  Created by Joshua Colley on 14/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//
//  VNTextObservation is a collection of VNRectangleObservations
//

import Foundation
import UIKit
import Vision

class FrameHelper {
    
    // MARK: - Frame Drawing Methods
    static func showWord(word: VNTextObservation, frame: CGRect, buffer: CVPixelBuffer) -> CALayer {
        guard let boxes = word.characterBoxes else { return CALayer() }
        
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
        for char in boxes {
            if char.bottomLeft.x < maxX { maxX = char.bottomLeft.x }
            if char.bottomRight.x > minX { minX = char.bottomRight.x }
            if char.bottomRight.y < maxY { maxY = char.bottomRight.y }
            if char.topRight.y > minY { minY = char.topRight.y }
        }
        
        let xCord = maxX * frame.size.width
        let yCord = (1 - minY) * frame.size.height
        let width = (minX - maxX) * frame.size.width
        let height = (minY - maxY) * frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.5
        outline.borderColor = UIColor.red.cgColor
        
        return outline
    }
    
    static func showLetter(letter: VNRectangleObservation, frame: CGRect) -> CALayer {
        let xCord = letter.topLeft.x * frame.size.width
        let yCord = (1 - letter.topLeft.y) * frame.size.height
        let width = (letter.topRight.x - letter.bottomLeft.x) * frame.size.width
        let height = (letter.topLeft.y - letter.bottomLeft.y) * frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        return outline
    }
    
    static func showFaceRect(face: VNFaceObservation, frame: CGRect) -> CALayer {
        let outline = CALayer()
        outline.borderColor = UIColor.red.cgColor
        outline.borderWidth = 1.0
        
        let frame = CGRect(x: (face.boundingBox.origin.x  * frame.size.width),
                           y: (face.boundingBox.origin.y  * frame.size.height) + 20.0,
                           width: (face.boundingBox.size.width  * frame.size.width),
                           height: (face.boundingBox.size.height  * frame.size.height) + 60.0 )
        outline.frame = frame
        return outline
    }
}

