//
//  ViewController.swift
//  FaceCounter
//
//  Created by Leo Tsuchiya on 11/26/17.
//  Copyright © 2017 Leo Tsuchiya. All rights reserved.
//
import UIKit
import Vision

class PhotoViewController: UIViewController {

    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    var faceRectangles = [BorderedView]()
//    var inputImage:UIImage?
    var imageView:UIImageView!
    let faceRectanglesRequest = VNDetectFaceRectanglesRequest()
    var scaledHeight:CGFloat?
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        view.addSubview(imageView)
        view.bringSubview(toFront: countLabel)
        view.bringSubview(toFront: selectImageButton)
        setImage(image: #imageLiteral(resourceName: "dorsey"))
        
        // Check for faces
//        let request = VNDetectFaceRectanglesRequest(completionHandler: { (vnrequest, error) in
//
//            if let error = error {
//                print("VNRequest Error:", error)
//            }
//            else {
//
//                if let numOfResults = vnrequest.results?.count {
//                    self.countLabel.text = "Faces detected: \(numOfResults)"
//                    self.view.bringSubview(toFront: self.countLabel)
//                }
//
//                vnrequest.results?.forEach({ (result) in
//                    print("result:",result)
//
//                    guard let faceObservation = result as? VNFaceObservation else { return }
//
//                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
//                    let height = scaledHeight * faceObservation.boundingBox.height
//                    imageView.backgroundColor = .black
//
//                    let topOfImageY = (imageView.bounds.height - scaledHeight) / 2
//                    let y = topOfImageY + (scaledHeight * (1 - faceObservation.boundingBox.origin.y)) - height
//
//                    let width = self.view.frame.width * faceObservation.boundingBox.width
//
//                    let faceRectangle = BorderedView(color: .red, frame: CGRect.zero)
//                    faceRectangle.frame = CGRect(x: x, y: y, width: width, height: height)
//                    self.view.addSubview(faceRectangle)
//
//                    print(faceObservation.boundingBox)
//                })
//            }
//            })
//
//        let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
//        do {
//            try handler.perform([request])
//        } catch let handlerError {
//            print("Handler perform error:",handlerError)
//        }
        
    }
    
    private func setImage(image:UIImage?) {
        guard let unwrappedImage = image else {
            return
        }
        imageView.image = unwrappedImage
        imageView.frame = self.view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        scaledHeight = view.frame.width / unwrappedImage.size.width * unwrappedImage.size.height
        detectFaces()
    }
    
    private func detectFaces() {
        guard let unwrappedImage = imageView.image?.cgImage else {
            return
        }
        let imageRequestHandler = VNImageRequestHandler(cgImage: unwrappedImage, options: [:])
        do {
            try imageRequestHandler.perform([faceRectanglesRequest])
            if let requestResult = faceRectanglesRequest.results as? [VNFaceObservation] {
                drawFaceRectangles(faceObservations: requestResult)
            }
        } catch let error {
            print("Error detecting faces: ",error)
        }
    }
    
    private func drawFaceRectangles(faceObservations:[VNFaceObservation]) {
        guard let unwrappedScaledHeight = scaledHeight else {
            return
        }
        
        for view in faceRectangles {
            view.removeFromSuperview()
        }
        faceRectangles.removeAll()
        countLabel.text = "Faces detected: \(faceObservations.count)"
        for faceObservation in faceObservations {
            print("drawing face")
            let x = self.view.frame.width * faceObservation.boundingBox.origin.x
            let height = unwrappedScaledHeight * faceObservation.boundingBox.height
            let topOfImageY = (imageView.bounds.height - unwrappedScaledHeight) / 2
            let y = topOfImageY + (unwrappedScaledHeight * (1 - faceObservation.boundingBox.origin.y)) - height
            let width = self.view.frame.width * faceObservation.boundingBox.width

            let faceRectangle = BorderedView(color: .red, frame: CGRect.zero)
            faceRectangle.frame = CGRect(x: x, y: y, width: width, height: height)
            self.view.addSubview(faceRectangle)
            faceRectangles.append(faceRectangle)
        }
    }

    
    @IBAction func selectImagePressed(_ sender: Any) {
        openPhotoLibrary()
    }
    
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            imagePicker.dismiss(animated: true, completion: nil)
        }
        guard let unwrappedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        print("metadata: ",unwrappedImage.imageOrientation)
        
        setImage(image: unwrappedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}
