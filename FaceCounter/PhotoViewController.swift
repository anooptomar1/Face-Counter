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
        guard let unwrappedImage = imageView.image else {
            return
        }
        
        let orientation = unwrappedImage.imageOrientation.getCGImagePropertyOrientation()
        
        guard let cgImage = unwrappedImage.cgImage else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
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
        view.bringSubview(toFront: countLabel)
        view.bringSubview(toFront: selectImageButton)
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
        setImage(image: unwrappedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImageOrientation {
    
    func getCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        }
    }
}
