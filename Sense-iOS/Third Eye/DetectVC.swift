//
//  DetectVC.swift
//  Third Eye
//
//  Created by Joshua Colley on 25/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit

class DetectVC: UIViewController {
    
    // MARK: - View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Actions
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
