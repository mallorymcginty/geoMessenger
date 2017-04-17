//
//  CameraViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 4/14/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit
import Firebase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    

    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    var storageRef: FIRStorageReference!
    
    func configureStorage()
    {
        let storageUrl = FIRApp.defaultApp()?.options.storageBucket
        storageRef = FIRStorage.storage().reference(forURL: "gs://" + storageUrl!)
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureStorage()
        
    }

    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imgPhoto.image = selectedImage
        }
        else
        {
            print("Error")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func  imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func savePhotoAlert()
    {
        let ac = UIAlertController(title: "Photo saved", message: "Your photo was saved successfully", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    
    
    @IBAction func btnSavePhoto(_ sender: UIBarButtonItem)
    {
        // get the image in the imageView and save it to the Photo Album
        let imageData = UIImageJPEGRepresentation(imgPhoto.image!, 0.8) // compression quality
        let compressedJPEGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
        
        // save to Firebase Storage

        
        let guid = UUID().uuidString
        
        let imagePath = "\(guid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        self.storageRef.child(imagePath)
            .put(imageData!, metadata: metadata) {  (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                
                // STEP 2b: Get the image URL
                let imageUrl = metadata?.downloadURL()?.absoluteString
                
                // STEP 3: Add code to save the imageURL to the Realtime database
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                
                let imageNode : [String : String] = ["ImageUrl": imageUrl!]
                
                // add to the Firebase JSON node for MyUsers
                ref.child("Photos").childByAutoId().setValue(imageNode) /**/
                
                // call the function to show the alert
                self.savePhotoAlert()
        }

    }
    
    
    
    
    
    
    

    @IBAction func btnTakePhoto(_ sender: UIButton)
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            imgPicker.allowsEditing = false
            // show the camera App
            self.present(imgPicker, animated: true, completion: nil)
        }
        
                
    }
    
    
    @IBAction func btnChoosePhoto(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            imgPicker.allowsEditing = true // allow users to crop , etc.
            // show the photoLibrary
            self.present(imgPicker, animated: true, completion: nil)
        }
        
    }
    
    
    
    
}
