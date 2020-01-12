//
//  CaptureVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 13/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit
import AVKit
import Vision

class CaptureVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var videoWrapper: UIView!
    @IBOutlet weak var detectButton: UIButton!
    
    var videoInput: AVCaptureDeviceInput!
    var videoOutput: AVCaptureVideoDataOutput!
    var cameraOutput = AVCapturePhotoOutput()
    var session = AVCaptureSession()
    
    var cvBuffer: CVPixelBuffer?
    var cmSampleBuffer: CMSampleBuffer?
    var requests = [VNRequest]()
    var ocrType: OCRType?
    

    // MARK: - View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        detectButton.layer.cornerRadius = detectButton.frame.height / 2
        
        startLiveVideo()
        switchOutput()
        startTextRecognition()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.session.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        self.videoWrapper.layer.sublayers?[0].frame = self.videoWrapper.bounds
    }
    
    
    // MARK: - Actions
    @IBAction func detectButtonPressed(_ sender: UIButton) {
        captureImage(buffer: cvBuffer)
        displayActionsheet()
    }
    
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Capture Image
extension CaptureVC {
    fileprivate func captureImage(buffer: CVPixelBuffer?) {
        if let buffer = buffer {
            switchOutput()
            self.cvBuffer = buffer
        }
    }
    
    fileprivate func switchOutput() {
        if session.outputs.contains(videoOutput) {
            self.session.removeOutput(videoOutput)
            self.session.addOutput(cameraOutput)
        } else if session.outputs.contains(cameraOutput) {
            self.session.removeOutput(cameraOutput)
            self.session.addOutput(videoOutput)
        }
    }
}


// MARK: - Video Layer
extension CaptureVC {
    fileprivate func startLiveVideo() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        // Input
        if self.videoInput == nil {
            self.videoInput = try? AVCaptureDeviceInput(device: device)
            self.session.addInput(self.videoInput)
        }
        
        // Output
        if self.videoOutput == nil {
            self.videoOutput = AVCaptureVideoDataOutput()
            let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
            
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            self.videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            self.session.addOutput(self.videoOutput)
        }
        
        // Start Capture Session
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = .resizeAspectFill
        self.videoWrapper.layer.addSublayer(layer)
    }
}


// MARK: - Vision Text Recognition
extension CaptureVC {
    fileprivate func startTextRecognition() {
        let textRequests = VNDetectTextRectanglesRequest { (request, error) in
            if error == nil {
                self.textRecognitionHandler(request: request)
            }
        }
        textRequests.reportCharacterBoxes = true
        self.requests = [textRequests]
    }

    fileprivate func textRecognitionHandler(request: VNRequest) {
        guard let observations = request.results else { return }
        let result = observations.map({ $0 as? VNTextObservation })

        DispatchQueue.main.async {
            self.videoWrapper.layer.sublayers?.removeSubrange(1...)
            for region in result {
                guard let word = region else { continue }
                guard let buffer = self.cvBuffer else { return }

                let wordBox = FrameHelper.showWord(word: word,
                                                   frame: self.videoWrapper.frame,
                                                   buffer: buffer)
                self.videoWrapper.layer.addSublayer(wordBox)

                if let letters = region?.characterBoxes {
                    for letter in letters {
                        let letterBox = FrameHelper.showLetter(letter: letter,
                                                               frame: self.videoWrapper.frame)
                        self.videoWrapper.layer.addSublayer(letterBox)
                    }
                }
            }
        }
    }
    
    fileprivate func detectPage() {
        let textRequests = VNDetectTextRectanglesRequest { (request, error) in
            if error == nil {
                self.detectRectHandler(request: request)
            }
        }
        textRequests.reportCharacterBoxes = true
        self.requests = [textRequests]
    }
    
    fileprivate func detectRectHandler(request: VNRequest) {
        guard let observations = request.results else { return }
        let result = observations.map({ $0 as? VNTextObservation })
        
        DispatchQueue.main.async {
            self.videoWrapper.layer.sublayers?.removeSubrange(1...)
            for region in result {
                guard let word = region else { continue }
                guard let buffer = self.cvBuffer else { return }

                let wordBox = FrameHelper.showWord(word: word,
                                                   frame: self.videoWrapper.frame,
                                                   buffer: buffer)
                self.videoWrapper.layer.addSublayer(wordBox)

                if let letters = word.characterBoxes {
                    for letter in letters {
                        let letterBox = FrameHelper.showLetter(letter: letter,
                                                               frame: self.videoWrapper.frame)
                        self.videoWrapper.layer.addSublayer(letterBox)
                    }
                }
            }
        }
    }
}


// MARK: - Video Output Delegate
extension CaptureVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let cvBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.cvBuffer = cvBuffer
        self.cmSampleBuffer = sampleBuffer
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        guard let orientation = CGImagePropertyOrientation(rawValue: 6) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: cvBuffer,
                                                        orientation: orientation,
                                                        options: requestOptions)
        try? imageRequestHandler.perform(self.requests)
    }
}


// MARK: - Prepare for Segue
extension CaptureVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReadVC {
            destination.cvBuffer = self.cvBuffer
            destination.cmSampleBuffer = self.cmSampleBuffer
            destination.imageFrame = self.videoWrapper.frame
            destination.detectionType = self.ocrType
        }
    }
}


// MARK: - Helper Methods
extension CaptureVC {
    fileprivate func displayActionsheet() {
        let vc = UIAlertController(title: "OCR",
                                   message: "Choose a service",
                                   preferredStyle: .actionSheet)
        
        let vision = UIAlertAction(title: "Vision", style: .default) { (_) in
            self.carryoutSegue(ocr: .vision)
        }
        let tesseract = UIAlertAction(title: "Tesseract", style: .default) { (_) in
            self.carryoutSegue(ocr: .tesseract)
        }
        let azure = UIAlertAction(title: "Azure", style: .default) { (_) in
            self.carryoutSegue(ocr: .azure)
        }
        let aws = UIAlertAction(title: "Amazon Web Services", style: .default) { (_) in
            self.carryoutSegue(ocr: .aws)
        }
        let _ = UIAlertAction(title: "Google Cloud", style: .default) { (_) in
            self.carryoutSegue(ocr: .googleCloud)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.switchOutput()
        }
        
        vc.addAction(vision)
        vc.addAction(tesseract)
        vc.addAction(azure)
        vc.addAction(aws)
//        vc.addAction(googleServices)
        vc.addAction(cancel)
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func carryoutSegue(ocr: OCRType) {
        self.ocrType = ocr
        performSegue(withIdentifier: "detectSegue", sender: self)
    }
}

// MARK: - Segue Enum
enum OCRType {
    case vision
    case azure
    case tesseract
    case aws
    case googleCloud
}
