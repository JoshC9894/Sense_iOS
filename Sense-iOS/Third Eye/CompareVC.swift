//
//  CompareVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 16/05/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit
import AWSCore
import AWSRekognition
import AVKit
import Vision


class CompareVC: UIViewController {
    
    // MARK: - Properties
    let id = ""
    
    var videoInput: AVCaptureDeviceInput!
    var videoOutput: AVCaptureVideoDataOutput!
    var cameraOutput = AVCapturePhotoOutput()
    var session = AVCaptureSession()
    
    var cvBuffer: CVPixelBuffer?
    var requests = [VNRequest]()
    
    @IBOutlet weak var previewImageVIew: UIImageView!
    @IBOutlet weak var source: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var compareButton: UIButton!
    
    
    // MARK: - View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        compareButton.layer.cornerRadius = compareButton.frame.height / 2.0
        
        startVideoSession()
        startFaceDetection()
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
        self.source.layer.sublayers?[0].frame = self.source.bounds
    }
    
    
    // MARK: - Actions
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func compareAction(_ sender: Any) {
        self.detectFaceInLastFrame()
        self.session.stopRunning()
    }
    
    // MARK: - Helper Methods
    fileprivate func startVideoSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
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
        self.source.layer.addSublayer(layer)
    }
    
    fileprivate func startFaceDetection() {
        let faceRequests = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.source.layer.sublayers?.removeSubrange(1...)
                    guard let observations = request.results else { return }
                    let result = observations.map({ $0 as? VNFaceObservation })
                    result.forEach { (face) in
                        if let face = face {
                            let box = FrameHelper.showFaceRect(face: face,
                                                               frame: self.source.frame)
                            self.source.layer.addSublayer(box)
                        }
                    }
                }
            }
        }
        self.requests = [faceRequests]
    }

    func compareFaces(source: UIImage) {
        let client = AWSRekognition.default()
        
        let sourceImage = AWSRekognitionImage()
        sourceImage?.bytes = UIImageJPEGRepresentation(source, 1.0)
        
        let targetImage = AWSRekognitionImage()
        targetImage?.bytes = UIImageJPEGRepresentation(UIImage(named: "target")!, 1.0)
        
        if let request = AWSRekognitionCompareFacesRequest() {
            request.sourceImage = sourceImage
            request.targetImage = targetImage
            
            client.compareFaces(request, completionHandler: { (response, error) in
                if error == nil {
                    let bestMatch = response?.faceMatches?.first
                    DispatchQueue.main.async {
                        if bestMatch == nil { self.label.text = "No match found" }
                        if let similarity = bestMatch?.similarity {
                            self.label.text = "Match Similarity = \(similarity)%"
                        } else {
                            self.label.text = "No match found"
                        }
                        self.session.startRunning()
                    }
                    debugPrint("@DEBUG: No Error")
                } else {
                    debugPrint("@DEBUG: Error - \(error.debugDescription)")
                    self.session.startRunning()
                }
            })
        }
    }
    
    fileprivate func detectFaceInLastFrame() {
        let faceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if error == nil {
                guard let observations = request.results else { print("No Result"); return }
                let result = observations.map({$0 as? VNFaceObservation})
                result.forEach({ (face) in
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: self.cvBuffer!))
                    if let image = self.cropFaceImage(image: image, observation: face) {
                        self.previewImageVIew.image = image
                        self.compareFaces(source: image)
                    }
                })
            } else {
                debugPrint("@DEBUG: Error - \(error.debugDescription)")
            }
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: self.cvBuffer!,
                                                   orientation: .right,
                                                   options: [:])
        try? requestHandler.perform([faceRequest])
    }
    
    fileprivate func cropFaceImage(image: UIImage, observation: VNFaceObservation?) -> UIImage? {
        
        if let observation = observation {
            let frame = CGRect(x: (observation.boundingBox.origin.x  * image.size.width) - 160,
                               y: (observation.boundingBox.origin.y  * image.size.height) + 0,
                               width: (observation.boundingBox.size.width  * image.size.width) + 320,
                               height: (observation.boundingBox.size.height  * image.size.height) + 320 )
            
            let context = CIContext()
            if let ciImage = image.ciImage {
                let cgImage = context.createCGImage(ciImage.oriented(.right), from: CGRect(origin: CGPoint(x: 0, y: 0),
                                                                                           size: image.size))
                guard let croppedImage = cgImage?.cropping(to: frame) else { return nil }
                return UIImage(cgImage: croppedImage)
            }
        }
        
        return nil
    }
}

// MARK: - AVCaptureVideo Output Delegate
extension CompareVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let cvBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.cvBuffer = cvBuffer
        
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
