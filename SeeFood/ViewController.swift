//
//  ViewController.swift
//  SeeFood
//
//  Created by Udit Kapahi on 21/03/18.
//  Copyright © 2018 Udit Kapahi. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = userPickedImage
            // convert the above ui image to CI image called as core image
            // this is a speacial type of image that will allow us to use coreml and vision framework to get interpretation out of it
            guard let ciImage = CIImage(image: userPickedImage) else {fatalError("Could not convert UI Image to CI Image")}
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        //        here we are going to use inception v3 model
        //load up the model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading core ml model failed")}
        
        //ask the model to classify data that we passed
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Results failed : \(error)")}
            
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier
//                if firstResult.identifier.contains("hotdog"){
//                    self.navigationItem.title = "Hot Dog"
//                }else{
//                    self.navigationItem.title = "Not Hot Dog"
//                }
            }
        }
        
        //pass the data using handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try! handler.perform([request])
        }catch {
            print("Error in performing \(error)")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

