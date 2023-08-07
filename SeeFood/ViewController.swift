//
//  ViewController.swift
//  SeeFood
//
//  Created by Fernando González on 04/08/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.imagePicker.delegate = self
        // We will use the camera source
        self.imagePicker.sourceType =  .photoLibrary
        // For allows to editing the image as the crop
        self.imagePicker.allowsEditing = false
        
    }
    
    private func detect(for image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model) else {
            fatalError("Loading CoreML Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            if error != nil {
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process")
            }
            
            if let firstResult = results.first {
                
                DispatchQueue.main.async {
                    self.descriptionLabel.text = "It is a  \(firstResult.identifier)"
                }
                
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    
    @IBAction func cameraBtnPressed(_ sender: UIBarButtonItem) {
        
        // To present the imagePickerController
        present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Time when the user has choosed an image
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            self.photoImageView.image = userPickedImage
            
            guard let ciimage: CIImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            self.detect(for: ciimage)
            
        }
        
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}

// MARK: - UINavigationControllerDelegate

extension ViewController: UINavigationControllerDelegate {
    
}

