//
//  VideoCaptureViewController.swift
//  FaceCounter
//
//  Created by Leo Tsuchiya on 11/26/17.
//  Copyright © 2017 Leo Tsuchiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Vision

class VideoCaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var redView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self as! AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
//        let testView = UIView()
//        testView.backgroundColor = .blue
//        testView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        self.view.addSubview(testView)
        
        self.view.backgroundColor = UIColor.brown
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: [:])
        
        
        let request = VNDetectFaceRectanglesRequest(completionHandler: { (vnrequest, error) in
            
            if let error = error {
                print("VNRequest Error:", error)
            }
            else {
                print("Good request:", vnrequest)
                
                if vnrequest.results?.count == 0 {
                    DispatchQueue.main.async {
                        self.redView.removeFromSuperview()
                    }
                }
                
                vnrequest.results?.forEach({ (result) in
                    print("result:",result)
                    
                    guard let faceObservation = result as? VNFaceObservation else { return }
                    
                    
                    DispatchQueue.main.async {
//                        let redView = UIView()
                        
                        let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                        let height = self.view.frame.height * faceObservation.boundingBox.height
                        
                        let y = self.view.frame.height * faceObservation.boundingBox.origin.y
                        
                        let width = self.view.frame.width * faceObservation.boundingBox.width

                        
                        self.redView.backgroundColor = .red
                        self.redView.alpha = 0.5
                        self.redView.frame = CGRect(x: x, y: y, width: width, height: height)
                        self.view.addSubview(self.redView)
                        self.view.bringSubview(toFront: self.redView)
                    }
                    
                    print(faceObservation.boundingBox)
                })
            }
        })
        
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let videoHandler = VNSequenceRequestHandler()
        do {
            try videoHandler.perform([request], on: ciImage)
        } catch let handlerError {
            print("Handler perform error:",handlerError)
        }
        
        
//        do {
//            try handler.perform([request])
//        } catch let handlerError {
//            print("Handler perform error:",handlerError)
//        }
        
    }
}


















