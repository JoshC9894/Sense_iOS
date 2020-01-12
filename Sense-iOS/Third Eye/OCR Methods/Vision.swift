//
//  Vision.swift
//  Third Eye
//
//  Created by Joshua Colley on 22/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit
import Vision

class Vision {
    let delegate: ReadVCProtocol
    let image: UIImage
    
    init(delegate: ReadVCProtocol, image: UIImage) {
        self.delegate = delegate
        self.image = image
    }
    
    func detectText(buffer: CVPixelBuffer) {
        let request = VNDetectTextRectanglesRequest(completionHandler: detectTextCompletion)
        request.reportCharacterBoxes = true
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer,
                                            orientation: .right,
                                            options: [:])
        try? handler.perform([request])
    }
    
    fileprivate func detectTextCompletion(request: VNRequest, error: Error?) {
        if error == nil {
            guard let observations = request.results else { return }
            let result = observations.map({ $0 as? VNTextObservation })
            
            DispatchQueue.main.async {
                var charArray: [String] = []
                result.forEach({ (word) in
                    if let word = word, let boxes = word.characterBoxes {
                        boxes.forEach({ (box) in
                            guard let croppedImage = self.cropImage(observation: box, image: self.image),
                                  let letter = self.classifyImage(image: croppedImage) else { return }
                            charArray.append(letter)
                        })
                    }
                })
                self.delegate.displayData(text: self.formatStringArray(array: charArray))
                self.delegate.stopAnimation()
            }
        }
    }
    
    fileprivate func cropImage(observation box: VNRectangleObservation, image: UIImage) -> CGImage? {
        let x = box.topLeft.x * image.size.width
        let y = box.topLeft.y * image.size.height
        let w = (box.topRight.x - box.topLeft.x) * image.size.width
        let h = (box.topLeft.y - box.bottomLeft.y) * image.size.height
        
        let frame = CGRect(x: x, y: y, width: w, height: h)
        
        if let cgImage = image.cgImage {
            return cgImage.cropping(to: frame)
        }
        return nil
    }
    
    fileprivate func formatStringArray(array: [String]) -> String {
        debugPrint(array)
        return ""
    }
}

// MARK: - Image Classification
extension Vision {
    fileprivate func classifyImage(image: CGImage) -> String? {
        var letter = ""
        guard let model = try? VNCoreMLModel(for: Turi_Create().model) else { return nil }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            let topResult = results.first
            if let identifier = topResult?.identifier {
                letter = identifier
            }
        }
        let handler = VNImageRequestHandler(cgImage: image,
                                            orientation: .up,
                                            options: [:])
        try? handler.perform([request])
        return letter
    }
}
