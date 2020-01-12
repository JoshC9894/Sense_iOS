//
//  ReadVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 13/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit
import AVKit
import CoreML
import Vision
import TesseractOCR
import Lottie

protocol ReadVCProtocol {
    func startAnimation()
    func stopAnimation()
    func displayData(text: String)
}

class ReadVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var detectedImageView: UIImageView!
    @IBOutlet weak var detectedTextLabel: UITextView!
    @IBOutlet weak var lottieWrapper: UIView!
    
    var animationView: LOTAnimationView!
    
    var cvBuffer: CVPixelBuffer?
    var cmSampleBuffer: CMSampleBuffer?
    
    var image: CIImage?
    var imageFrame: CGRect?
    var detectionType: OCRType?
    
    var requests = [VNRequest]()
    var letters = [String]()
    var confidences = [String]()
    
    
    // MARK: - View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.letters = []
        self.confidences = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.detectText()
        self.startAnimation()
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Helper Methods
extension ReadVC {
    fileprivate func detectText() {
        guard let detectionType = self.detectionType,
              let cvBuffer = self.cvBuffer,
              let image = createImageFromBuffer(buffer: cvBuffer)
        else { return }
        
        switch detectionType {
        case .vision: Vision(delegate: self, image: image).detectText(buffer: cvBuffer)
        case .azure: Azure(delegate: self).detectText(image: image)
        case .tesseract: Tesseract(delegate: self).detectText(image: image)
        case .aws: AWS(delegate: self).detectText(image: image)
        default: break
        }
    }
    
    fileprivate func createImageFromBuffer(buffer: CVPixelBuffer) -> UIImage? {
        let context = CIContext()
        let ciImage = CIImage(cvPixelBuffer: buffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Animation Delegate
extension ReadVC: ReadVCProtocol {
    func startAnimation() {
        self.lottieWrapper.isHidden = false
        self.animationView = LOTAnimationView(name: "loader_black")
        
        let w = lottieWrapper.frame.size.width
        let h = lottieWrapper.frame.size.height
        animationView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        self.lottieWrapper.addSubview(animationView)
        
        animationView.loopAnimation = true
        animationView.play(fromProgress: 0, toProgress: 1.0)
    }
    
    func stopAnimation() {
        self.animationView.stop()
        self.lottieWrapper.isHidden = true
    }
    
    func displayData(text: String) {
        self.detectedTextLabel.text = text
    }
}

