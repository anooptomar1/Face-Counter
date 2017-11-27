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

enum CameraDirection {
    case front
    case back
}

class VideoCaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var faceRectangles = [BorderedView]()
    var detectFaceRequest = VNDetectFaceRectanglesRequest()
    var requestHandler = VNSequenceRequestHandler()
    var captureSession = AVCaptureSession()
    var currentCamera = CameraDirection.front
    
    @IBOutlet weak var switchCameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        redView = BorderedView(color: UIColor.red, frame: CGRect.zero)
        
        setupAVSession(cameraDirection: currentCamera)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        view.bringSubview(toFront: switchCameraButton)
    }
    
    func setupAVSession(cameraDirection:CameraDirection) {
        var setupDevice:AVCaptureDevice?
        if cameraDirection == .back {
            setupDevice = AVCaptureDevice.default(for: .video)
        }
        if cameraDirection == .front {
            setupDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
        guard let captureDevice:AVCaptureDevice = setupDevice else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.beginConfiguration()
        
        while let captureInput = captureSession.inputs.first {
            captureSession.removeInput(captureInput)
        }
        captureSession.addInput(input)
        
        if captureSession.outputs.isEmpty {
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            dataOutput.alwaysDiscardsLateVideoFrames =  true
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    @IBAction func switchCameraButtonPressed(_ sender: Any) {
        if currentCamera == .front {
            currentCamera = .back
        }
        else {
            currentCamera = .front
        }
        setupAVSession(cameraDirection: currentCamera)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: [:])
        
        // Playing with orientations why does this matter?
        // Can types work other than ciimage? pixel buffer?
        var setupImage:CIImage?
        if currentCamera == .front {
            setupImage = ciImage.oriented(.leftMirrored)
        }
        if currentCamera == .back {
            setupImage = ciImage.oriented(.right)
        }
        guard let orientedImage:CIImage = setupImage else {
            return
        }
        detectFaces(image: orientedImage)
    }
    
    func detectFaces(image:CIImage) {
        do {
            try requestHandler.perform([detectFaceRequest], on: image)
            if let requestResults = detectFaceRequest.results as? [VNFaceObservation] {
                if requestResults.isEmpty {
                    DispatchQueue.main.async {
                        for view in self.faceRectangles {
                            view.removeFromSuperview()
                        }
                    }
                }
                else {
                    // Only create the view for the first face found
                    drawRectangle(faceObservations: requestResults)
                    
                }
            }
        } catch let handlerError {
            print("Bad request perform:",handlerError)
        }
    }
    
    func drawRectangle(faceObservations:[VNFaceObservation]) {
        
        for (index, faceObservation) in faceObservations.enumerated() {
            DispatchQueue.main.async {
                let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                let height = self.view.frame.height * faceObservation.boundingBox.height
                let y = self.view.frame.height * (1 - faceObservation.boundingBox.origin.y) - height
                let width = self.view.frame.width * faceObservation.boundingBox.width
                
                if self.faceRectangles.count <= index {
                    self.faceRectangles.append(BorderedView(color: UIColor.red, frame: CGRect.zero))
                }
                self.faceRectangles[index].frame = CGRect(x: x, y: y, width: width, height: height)
                self.view.addSubview(self.faceRectangles[index])
            }
        }
    }
}


















