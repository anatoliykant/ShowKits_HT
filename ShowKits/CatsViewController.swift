//
//  CatsViewController.swift
//  ShowKits
//
//  Created by anatoliy.kant on 04.02.16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
//import CoreLocation

class CatsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var apiClient = APIClient()
    var photos:[Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func showMeCats(sender: AnyObject) {
        
        let radius:Double = 5
        apiClient.find("cat",
            longitude: mapView.centerCoordinate.longitude,
            latitude: mapView.centerCoordinate.latitude,
            radius: radius) { (success, faiilure) -> Void in
                
                //print(success)
                self.photos = success
                self.updateMapView()
        }
    }
    func updateMapView() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if self.photos != nil {
        self.mapView.addAnnotations(self.photos!)
        }
    }
}

extension CatsViewController:CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse, CLAuthorizationStatus.AuthorizedAlways:
            self.mapView.showsUserLocation = true
            
            
        default:
            print("User denied location")
        }
    }
}

extension CatsViewController:MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        
        guard let photoToShow = annotation as? Photo else {
            return nil
        }
        
        var photoView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationIdentifier)
        
        if photoView == nil {
            photoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationIdentifier)
        }
        
        let imageView = UIImageView(frame: Constants.imageViewFrame)
        imageView.contentMode = .ScaleAspectFill
        
        photoView?.leftCalloutAccessoryView = imageView
        photoView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        //чтобы показать кнопки на 
        photoView?.canShowCallout = true
        
        
        
        return photoView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let imageView = view.leftCalloutAccessoryView as? UIImageView, let photoToShow = view.annotation as? Photo else {
            return
        }
        
        //update(imageView, url: photoToShow.photoURL)
        
        //return
        imageView.updateImageWith(photoToShow)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("Show Image Details", sender: view.annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let detailedPhoto = segue.destinationViewController as? PhotoDetailiedViewController,
            let photo = sender as? Photo else {
                return
        }
        
        detailedPhoto.photo = photo
    }
    
    func update(imageView:UIImageView, url:String) {
        guard let url = NSURL(string: url) else {
                return
        }
        
        guard let data = NSData(contentsOfURL: url) else {
            return
        }
        
        let image = UIImage(data: data)
        
        imageView.image = image
        
    }
}


//MARK: - Constants

extension CatsViewController {
    private struct Constants {
        static let AnnotationIdentifier = "PhotoAnnotationView"
        static let imageViewFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
    }
}

//MARK: -UIImageView Extention

extension UIImageView {
    private struct Constants {
        static let defaultIconWidth = 240
    }
    func updateImageWith(photo:Photo?) {
        guard let photoToApply = photo else {
            self.image = nil
            return
        }
        
        let width = photoToApply.iconWidth > 0 ? photoToApply.iconWidth : Constants.defaultIconWidth
        
        let url = CGFloat(width) > frame.size.width ? photoToApply.iconURL : photoToApply.photoURL
        
        sd_setImageWithURL(NSURL(string: url),
            placeholderImage: nil,
            options: [.ProgressiveDownload])
        
    }
}