//
//  Tesseract.swift
//  Third Eye
//
//  Created by Joshua Colley on 22/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation
import AVKit
import TesseractOCR

class Tesseract: NSObject {
    let delegate: ReadVCProtocol
    
    init(delegate: ReadVCProtocol) {
        self.delegate = delegate
    }
    
    func detectText(image: UIImage) {
        let uiImage = image.g8_blackAndWhite()
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = uiImage
            
            DispatchQueue.main.async {
                self.delegate.displayData(text: tesseract.recognizedText)
                self.delegate.stopAnimation()
            }
        }
    }
}

// MARK: - Tesseract Delegate
extension Tesseract: G8TesseractDelegate {
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        debugPrint("Progress: \(tesseract.progress)")
    }
}


