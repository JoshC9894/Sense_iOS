//
//  ListenVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 24/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit
import Speech

class ListenVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var listenButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-GB"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isListening: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        
        listenButton.layer.cornerRadius = listenButton.frame.height / 2
        listenButton.isEnabled = false
        speechRecognizer?.delegate = self
        requestSpeechAuth()
    }
    
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listenButtonAction(_ sender: UIButton) {
        
        isListening = !isListening
        if isListening {
            listenButton.setTitle("Stop Listening", for: .normal)
            self.recordAndRecogniseSpeech()
        } else {
            listenButton.setTitle("Listen", for: .normal)
            audioEngine.stop()
            recognitionTask?.cancel()
        }
    }
    
    // MARK: - Helper Methods
    fileprivate func recordAndRecogniseSpeech() {
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        if let recogniser = SFSpeechRecognizer(), recogniser.isAvailable {
            self.recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                if let result = result, error == nil {
                    let bestString = result.bestTranscription.formattedString
                    self.textView.text = bestString
                }
            })
        }
    }
    
    fileprivate func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                switch authState {
                case .authorized:
                    self.listenButton.isEnabled = true
                    
                case .denied:
                    self.displayAlert(message: "Denied access to speech recognition")
                    self.listenButton.isEnabled = false
                    
                case .restricted:
                    self.displayAlert(message: "Speech recognition restricted on this device")
                    self.listenButton.isEnabled = false
                    
                case .notDetermined:
                    self.displayAlert(message: "Speech recognition not yet authorized")
                    self.listenButton.isEnabled = false
                }
            }
        }
    }
}

extension ListenVC: SFSpeechRecognizerDelegate {
}
