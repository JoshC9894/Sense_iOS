//
//  AWS.swift
//  Third Eye
//
//  Created by Joshua Colley on 23/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSRekognition

protocol CompareVCProtocol {
    func displayData()
}

class AWS {
    let delegate: ReadVCProtocol!
    let id = ""
    
    init(delegate: ReadVCProtocol) {
        self.delegate = delegate
    }
    
    func detectText(image: UIImage) {
        let client = AWSRekognition.default()
        let awsImage = AWSRekognitionImage()
        awsImage?.bytes = UIImageJPEGRepresentation(image, 1.0)
        
        guard let request = AWSRekognitionDetectTextRequest() else { return }
        request.image = awsImage
        client.detectText(request) { (response, error) in
            if error == nil {
                var string = ""
                response?.textDetections?.forEach({ (detection) in
                    string = string + (detection.detectedText ?? "")
                })
                DispatchQueue.main.async {
                    self.delegate?.displayData(text: string)
                    self.delegate?.stopAnimation()
                }
            }
        }
    }
}
