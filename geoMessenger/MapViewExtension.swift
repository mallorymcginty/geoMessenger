//
//  MapViewExtension.swift
//  geoMessenger
//
//  Created by Ivor D. Addo, PhD on 3/4/17.
//  Copyright © 2017 Mallory McGinty. All rights reserved.
//

import UIKit
import MapKit
import Firebase

extension FirstViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Message
        {
            let identifier = "Pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else
            {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -8, y: -5)
                view.pinTintColor = .green
                view.animatesDrop = true
                //view.image = UIImage(named: "mapButtonOff.png")
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
            }
            return view
        }
        return nil
    }


func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
{
    let message = view.annotation as! Message
    let placeName = message.title
    let placeInfo = message.subtitle
    
    let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    //add a button to remove annotation
    ac.addAction(UIAlertAction(title: "Remove", style: .default)
    {
        (result : UIAlertAction) -> Void in
        mapView.removeAnnotation(message)
    })
    present(ac, animated: true)
}


override func viewDidLoad()
{
    super.viewDidLoad()
    
    //Set initial location to MU
    let initialLocation = CLLocation(latitude: 43.038611, longitude: -87.928759)
    centerMapOnLocation(location: initialLocation)
    
    mapView.delegate = self
    
    //Show messages on the map
    let message = Message(title: "The Bucks are legit!", locationName: "Bradley Center", username: "John Smith", coordinate: CLLocationCoordinate2D(latitude: 43.043914, longitude: -87.917262), isDisabled: false)
    
    mapView.addAnnotation(message)
}
}




