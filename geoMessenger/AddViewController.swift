//
//  AddViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 3/26/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBOutlet weak var txtFirst: UITextField!
    @IBOutlet weak var txtLast: UITextField!
    
    @IBAction func btnAddUser(_ sender: CustomButton) {
        
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference()
        
        let userTable : [String : Any] =
            ["FirstName": txtFirst.text!,
             "LastName": txtLast.text!,
             "IsApproved": false]
        
        // add to the Firebase JSON node for MyUsers
        ref.child("MyUsers").childByAutoId().setValue(userTable)
        
        // show confirmation alert
        let ac = UIAlertController(title: "User Saved!", message:"The user information  was saved successfully!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
        // reset controls
        txtLast.text = nil
        txtFirst.text = nil

        
        
    }

    
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
