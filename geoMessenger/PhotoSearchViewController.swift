//
//  PhotoSearchViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 4/14/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Alamofire
import VisualRecognitionV3

class PhotoSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    let apiKey = "ce5c9a38c2dd1868be46cd7bff62d587e38aaef3"
    let version = "2017-04-17"
    
    let watsonCollectionName = "PhotoCollection" // watson collection id
    var watsonCollectionId = "PhotoCollection" // watson collection id
    
    
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnSearch: UIButton!
    
    
    
    
    var ref: FIRDatabaseReference!
    
    var existingImageUrls: [ImageUrlItem] = []
    var similarImageUrls: [ImageUrlItem] = []
    var newPhotoRecognitionURL: URL!
    var visualRecognition: VisualRecognition!
    
    
    
    
    
    @IBAction func btnSearch(_ sender: UIButton)
    {
        self.btnSearch.isHidden = true
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
      
        let pickPhotoAction = UIAlertAction(title: "Pick from the Gallery", style: .default) { (alert: UIAlertAction!) in
            //Pick the image
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
            {
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = .photoLibrary
                imgPicker.allowsEditing = false
                //Show the photoLibrary
                self.present(imgPicker, animated: true, completion: nil)
            }
            self.showButton()
        }
        
        
        let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default) { (alert: UIAlertAction!) in
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = .camera
                imgPicker.allowsEditing = false
        // show the camera App
                self.present(imgPicker, animated: true, completion: nil)
            }
            self.showButton()
        }
        
        //use a cancel style with no action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
        // cancelled, show button and hide activity icon
            self.showButton()
        }
        
        
        optionMenu.addAction(pickPhotoAction)
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
    func showButton()
    {
        DispatchQueue.main.async
        {
            self.btnSearch.isHidden = false
        }
    }
    
    
    func hideButton()
    {
        DispatchQueue.main.async
        {
            self.btnSearch.isHidden = true
        }
    }
    
    
    var  storageRef: FIRStorageReference!
    
    func configureStorage()
    {
        let storageUrl = FIRApp.defaultApp()?.options.storageBucket
        storageRef = FIRStorage.storage().reference(forURL: "gs://" + storageUrl!)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imgPhoto.image = selectedImage
        }
        else
        {
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
        
        performSearch()
        
    }
    
    
    func performSearch()
    {
        self.hideButton()
        
        //Save the test image
        let imageData = UIImageJPEGRepresentation(imgPhoto.image!, 0.8)
        let compressedJPEGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
        
        //Save to Firebase Storage
        let guid =  "search_image" // substitute with the current user's ID
        
        let imagePath = "\(guid)/\(guid).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        self.storageRef.child(imagePath)
            .put(imageData!, metadata: metadata) {  (metadata, error) in
                if let error = error
                {
                    print("Error uploading: \(error)")
                    return
                }
                
                //Get the image URL
                //Limit the size of uploaded images to < 2MB
                self.newPhotoRecognitionURL = URL(string: (metadata?.downloadURL()?.absoluteString)!)!
                
                
                //Get a list of previous imageUrls from Firebase
                //This will be a batch submission but the MCS SDK doesn't support it yet
                
                self.ref = FIRDatabase.database().reference()
                
                //Get only the latest 15 photos for now
                self.ref.child("Photos").queryLimited(toLast: 4)
                    .observe(.value, with: { snapshot in
                        
                        //Loop through the children and append them to the new array
                        for dbItem in snapshot.children.allObjects
                        {
                            let gItem = (snapshot: dbItem )
                            
                            //Convert the snapshot JSON value to your Struct type
                            let newValue = ImageUrlItem(snapshot: gItem as! FIRDataSnapshot)
                            self.existingImageUrls.append(newValue)
                        }
                        
                        //Make call to API with searchImageUrl and existingImageUrls
                        
                        //Call IBM Watson here
                        self.visualRecognition = VisualRecognition(apiKey: self.apiKey, version: self.version)
                        
                        
                        //Classify the curent Image
                        self.classifyImage()
                        
                        
                        //Create a collection
                        self.createCollection()
                        
                        //Add images to the Watson collection
                        for existingImageUrlItem in self.existingImageUrls
                        {
                            
                            print(existingImageUrlItem.imageUrl)
                            self.addCurrentImageToCollection(imageURL: URL(string: existingImageUrlItem.imageUrl)!)
                        }
                        
                        //Find Similar Images
                        self.findSimilarImages()
                        
                        //Eventually permanently store new photo reports to the collection and eliminate the programmatic createCollection and removeCollection calls
                        
                        
                        
                        // TODO:
                        print(self.similarImageUrls)
                        
                        
                        
                        self.collectionView.reloadData()
                    })
        }
        
        self.showButton()
        
    
    }


    func createCollection()
    {
    // create a collection and
    self.visualRecognition.createCollection(withName: self.watsonCollectionName, success: { (collection) in
        
        self.watsonCollectionId = collection.collectionID
        print("Collection Created")
        print(self.watsonCollectionName)
        print(self.watsonCollectionId)
        })
    }



    func removeCollection()
    {
        // create a collection and
        self.visualRecognition.deleteCollection(withID: self.watsonCollectionId)
        print("Collection Removed")
    }




    func addCurrentImageToCollection(imageURL: URL)
    {
    // create a collection and
        self.visualRecognition.addImageToCollection(withID: self.watsonCollectionId, imageFile: imageURL) { (colImages) in
        // number of images
        print(colImages.collectionImages.count)
        }
    }




    func findSimilarImages()
    {
    print(newPhotoRecognitionURL! )
    print (self.watsonCollectionId)
    
    self.visualRecognition.findSimilarImages(toImageFile: newPhotoRecognitionURL!,
                                             inCollectionID: self.watsonCollectionId,
                                             limit: 9,
                                             failure: { (searchError) in
                                                //
                                                print(searchError)
                                                self.removeCollection()
    },
                                             success: { similarImageList in
                                                
                                                //self.visualRecognition.findSimilarImages(toImageFile: newPhotoRecognitionURL!, inCollectionID: self.watsonCollectionId, success: { similarImageList in
                                                //
                                                
                                                if let classifiedImage = similarImageList.similarImages.first
                                                {
                                                    print(classifiedImage.score!)
                                                    
                                                    var counter = 1
                                                    // loop through the children and append them to the new array
                                                    for similarImageItem in similarImageList.similarImages
                                                    {
                                                        
                                                        // only get top 9 similar images
                                                        //if counter < 9
                                                        //{
                                                        // convert the snapshot JSON value to your Struct type
                                                        let newValue = ImageUrlItem.init(imageUrl: similarImageItem.imageFile, key: String(counter))
                                                        self.similarImageUrls.append(newValue)
                                                        counter += 1
                                                        //}
                                                    }
                                                }
                                                else
                                                {
                                                    DispatchQueue.main.async
                                                        {
                                                        // show alert of failure
                                                        let ac = UIAlertController(title: "Photo Search Failed!", message:"Your photo search was not successful. Try again later", preferredStyle: .alert)
                                                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                                                        self.present(ac, animated: true)
                                                    }
                                                }
                                                self.removeCollection()
                                                
                })
    
    
            }
    





    func classifyImage()
    {
    //Determine if IBM Watson call failed
    let failure = {(error:Error) in
        DispatchQueue.main.async
        {
            //Show alert of failure
            let ac = UIAlertController(title: "Photo Search Failed!", message:"Your photo search was not successful. Try again later", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
        
        //Troubleshooting only
        print(error)
    }
    
        
        
    //Classify the image to show classified verbiage about the image
    self.visualRecognition.classify(image: (self.newPhotoRecognitionURL?.absoluteString)!, failure: failure){
        classifiedImages in
        
        if let classifiedImage = classifiedImages.images.first
        {
            print(classifiedImage.classifiers)
            
            if let results = classifiedImage.classifiers.first?.classes.first?.classification {
                
                DispatchQueue.main.async {
                    //Success: show the results in the title bar
                    self.title = results
                    
                }
                
            }
        }
        else
        {
            DispatchQueue.main.async
                {
                // show alert of failure
                let ac = UIAlertController(title: "Photo Search Failed!", message:"Your photo search was not successful. Try again later", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                }
            }
        }
    }



    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: { _ in })
    }



    
    
    
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
       
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int
    {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let reuseIdentifier = "PhotoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! PhotoCell
        cell.backgroundColor = UIColor.gray
        //Add customizations
        // on page load when we have no search results, show nothing
        if similarImageUrls.count > 0 {
            let image = self.similarImageUrls[indexPath.row]
            
            // get image asynchronously via URL
            let url = URL(string: image.imageUrl)
            
            DispatchQueue.global().async {
                //let data = try? Data(contentsOf: url!)
                //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.imgPhoto.af_setImage(withURL: url!) // change to this after alamofire is added
                    //cell.imgPhoto.image = UIImage(data: data!)
                }
            }
            
        }
        
        return cell
    }
    
    
}
