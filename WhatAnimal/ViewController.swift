//
//  ViewController.swift
//  WhatAnimal
//
//  Created by Ata Eran on 9/20/21.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let galleryPicker = UIImagePickerController()
    private let cameraPicker = UIImagePickerController()
    private let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    var animalDescription = ""
    var animalPicUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryPicker.delegate = self
        galleryPicker.sourceType = .photoLibrary
        galleryPicker.allowsEditing = true
        //        cameraPicker.delegate = self
        //        cameraPicker.sourceType = .camera
        //        cameraPicker.allowsEditing = true
    }
    
    // Uncomment when a physical device is connected
    
    //    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    //        present(cameraPicker, animated: true, completion: nil)
    //    }
    
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
        present(galleryPicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Error converting to CIImage.")
            }
            detect(animalImage: ciimage)
        }
        galleryPicker.dismiss(animated: true)
        
    }
    
    private func detect(animalImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: AnimalClassifier().model) else {
            fatalError("Cannot assign model.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Model could not execute request.")
            }
            self.fetchWiki(animalName: classification.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: animalImage)
        
        do {
            try handler.perform([request])
        } catch {
            fatalError("Error performing the request")
        }
        
    }
    
    private func fetchWiki(animalName: String) {
        let parameters: [String:String] =
            [
                "format" : "json",
                "action" : "query",
                "prop" : "extracts|pageimages",
                "exintro" : "",
                "explaintext" : "",
                "titles" : animalName,
                "indexpageids" : "",
                "redirects" : "1",
                "pithumbsize": "500",
            ]
        
        
        DispatchQueue.global().async {
            AF.request(self.wikipediaURL, method: .get, parameters: parameters).responseJSON { response in
                print(response.result)
                switch response.result {
                case .success(let value):
                    let animalJSON: JSON = JSON(value)
                    let pageid = animalJSON["query"]["pageids"][0].stringValue
                    self.animalDescription = animalJSON["query"]["pages"][pageid]["extract"].stringValue
                    self.animalPicUrl = animalJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toWiki", sender: self)
                    }
                case .failure(let value):
                    DispatchQueue.main.async {
                        print(value)
                        let alert = UIAlertController(title: "Cannot access Wikipedia.", message: "Please check your connection.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { action in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        )
                        )
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = WikiViewController()
        destinationVC.desc = animalDescription
        destinationVC.imgUrl = animalPicUrl
    }
}
