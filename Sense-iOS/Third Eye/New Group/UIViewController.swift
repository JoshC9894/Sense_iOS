//
//  ViewController.swift
//  Third Eye
//
//  Created by Joshua Colley on 24/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDelegate {
    func displayAlert(message: String)
}

extension AlertDelegate where Self: UIViewController {
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "FYI..!",
                                      message: message,
                                      preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController: AlertDelegate {
    
}
