//
//  ViewController.swift
//  FaceCounter
//
//  Created by Leo Tsuchiya on 11/26/17.
//  Copyright © 2017 Leo Tsuchiya. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "dorsey"))
        imageView.frame = self.view.bounds
        imageView.contentMode = .scaleAspectFit
        
        self.view.addSubview(imageView)
     
        // Check for faces
        let request = VNDetectFaceRectanglesRequest(completionHandler: { (vnrequest, error) in
            
            if let error = error {
                print("VNRequest Error:", error)
            }
            else {
                print("Good request:", vnrequest)
                
                vnrequest.results?.forEach({ (result) in
                    print("result:",result)
                    
                    guard let faceObservation = result as? VNFaceObservation else { return }
                    
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let height = imageView.frame.height * faceObservation.boundingBox.height
                    let y = imageView.frame.height * (1 - faceObservation.boundingBox.origin.y) - height
                    
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    
                    let redView = UIView()
                    redView.backgroundColor = .red
                    redView.alpha = 0.5
                    redView.frame = CGRect(x: x, y: y, width: width, height: height)
                    self.view.addSubview(redView)
                    
                    print(faceObservation.boundingBox)
                    
                    
                    
                    
                })
            }
            })
        
        let handler = VNImageRequestHandler(cgImage: #imageLiteral(resourceName: "dorsey").cgImage!, options: [:])
        do {
            try handler.perform([request])
        } catch let handlerError {
            print("Handler perform error:",handlerError)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

