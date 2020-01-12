//
//  InitialVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 24/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit
import Lottie
import AVFoundation

class InitialVC: UIViewController {

    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var hearButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var seeButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var animationWrapper: UIView!
    var animationView: LOTAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readButton.layer.cornerRadius = readButton.frame.height / 2
        hearButton.layer.cornerRadius = hearButton.frame.height / 2
        thirdButton.layer.cornerRadius = thirdButton.frame.height / 2
        seeButton.layer.cornerRadius = seeButton.frame.height / 2
        checkButton.layer.cornerRadius = checkButton.frame.height / 2
        
        self.readButton.alpha = 1.0
        self.hearButton.alpha = 1.0
        self.thirdButton.alpha = 1.0
        self.seeButton.alpha = 1.0

        self.animationView = LOTAnimationView(name: "hello")
        self.animationView.contentMode = .scaleAspectFit
        animationView.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                     size: CGSize(width: animationWrapper.frame.size.width,
                                                  height: animationWrapper.frame.size.height))
        
        animationWrapper.addSubview(animationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        animationView.play(fromProgress: 0, toProgress: 0.6) { (_) in
//            UIView.animate(withDuration: 0.25, animations: {
//                self.readButton.alpha = 1.0
//                self.hearButton.alpha = 1.0
//                self.thirdButton.alpha = 1.0
//                self.seeButton.alpha = 1.0
//            })
//        }
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
    }
    
    
    @IBAction func speakButtonAction(_ sender: Any) {
        speak(text: "Help me Obi-Wan Kenobi. You’re my only hope", voice: "en-US")
    }
    
    fileprivate func speak(text: String, voice: String) {
        let spk = AVSpeechSynthesizer()
        let voice = AVSpeechSynthesisVoice(language: voice)
        let toSay = AVSpeechUtterance(string: text)
        toSay.voice = voice
        spk.speak(toSay)
    }
    
}
