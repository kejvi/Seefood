//
//  ViewController.swift
//  Seafood
//
//  Created by Kejvi Peti on 2021-06-21.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            guard let ciimage = CIImage(image: image) else {
                 fatalError("Coverting image failed")
            }
            imagePicker.dismiss(animated: true, completion: nil)
            detectImage(image: ciimage)
        }
    }
    
    func detectImage(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Coreml image failed")
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Classification failed")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                }else{
                    self.navigationItem.title = "Not Hotdog"
                    self.navigationController?.navigationBar.barTintColor = UIColor.systemPink
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try! handler.perform([request])
        }catch{
            print(error)
        }
        
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
}

