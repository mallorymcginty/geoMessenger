//
//  FirstViewController.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 3/4/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit
import MapKit
import Firebase


class FirstViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    
    var messageNodeRef : FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        //Set initial location to MU
        let initialLocation = CLLocation (latitude: 43.038499, longitude: -87.938809)
        centerMapOnLocation(location: initialLocation)
        
        
        
        /*let message = Message(title: "The Bucks are legit", locationName: "Bradley Center", username: "John Smith", coordinate: CLLocationCoordinate2D(latitude: 43.043914, longitude: -87.917262), isDisabled: false)
         
         mapView.addAnnotation(message)
         
         //Show messages on the map
         let message = Message(title: "The Bucks are legit!",
         locationName: "Bradley Center",
         username: "John Smith",
         coordinate: CLLocationCoordinate2D(latitude: 43.043914, longitude: -87.917262))
         
         mapView.addAnnotation(message)
         */
        
        //create Firebase DB reference
        messageNodeRef = FIRDatabase.database().reference().child("messages")
        
        //use the observe handler to poll for realtime updates
        let pinMessageId = "msg-1"
        var pinMessage: Message?
        messageNodeRef.child(pinMessageId).observe(.value, with: {(snapshot: FIRDataSnapshot) in
            
            if let dictionary = snapshot.value as? [String: Any]
            {
                //If the pin already exists, remove it first
                if pinMessage != nil
                {
                    self.mapView.removeAnnotation(pinMessage!)
                }
                
                //map the JSON tags to the Message class' properties
                let pinLat = dictionary["latitude"] as! Double
                let pinLong = dictionary["longitude"] as! Double
                let messageDisabled = dictionary["isDisabled"] as! Bool
                
                let message = Message(title: (dictionary["title"] as? String)!,
                                      locationName: (dictionary["locationName"] as? String)!,
                                      username: (dictionary["username"] as? String)!,
                                      coordinate: CLLocationCoordinate2D(latitude: pinLat, longitude: pinLong),
                                      isDisabled: messageDisabled
                )
            
            pinMessage = message
            
            //if the message is not disabled, show the message as an annotation
            if !message.isDisabled
            {
                self.mapView.addAnnotation(message)
            }
            }
        })
        
    }

    
    
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation)
    {
        let  coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - location manager to authorize user location for maps app
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus()
    {
     if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
     {
        mapView.showsUserLocation = true
     }
     else
     {
        locationManager.requestWhenInUseAuthorization()
     }
    }
    
    
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
}

}
