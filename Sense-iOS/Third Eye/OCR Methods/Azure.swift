//
//  Azure.swift
//  Third Eye
//
//  Created by Joshua Colley on 23/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

class Azure {
    let keyOne = ""
    let keyTwo = ""
    let endPoint = ""
    
    var delegate: ReadVCProtocol
    
    init(delegate: ReadVCProtocol) {
        self.delegate = delegate
    }
    
    func detectText(image: UIImage) {
        if let url = URL(string: self.endPoint) {
            var request = URLRequest(url: url)
            
            request.setValue(keyOne, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = UIImagePNGRepresentation(image)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                if error == nil {
                    if let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject] {
                        DispatchQueue.main.async {
                            self.delegate.displayData(text: self.extractStringsFromDictionary(results).first ?? "No Text Found.")
                            self.delegate.stopAnimation()
                        }
                    }
                }
            }
            task.resume()
        }
    }

    fileprivate func extractStringsFromDictionary(_ dictionary: [String : AnyObject]) -> [String] {
        if dictionary["regions"] != nil {
            var extractedText : String = ""
            
            if let regionsz = dictionary["regions"] as? [AnyObject]{
                for reigons1 in regionsz
                {
                    if let reigons = reigons1 as? [String:AnyObject]
                    {
                        let lines = reigons["lines"] as! NSArray
                        print (lines)
                        for words in lines{
                            if let wordsArr = words as? [String:AnyObject]{
                                if let dictionaryValue = wordsArr["words"] as? [AnyObject]{
                                    for a in dictionaryValue {
                                        if let z = a as? [String : String]{
                                            print (z["text"]!)
                                            extractedText += z["text"]! + " "
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            // Get text from words
            return [extractedText]
        }
        else
        {
            return [""];
        }
    }
}
