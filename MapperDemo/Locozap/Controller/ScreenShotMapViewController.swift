//
//  ScreenShotMapViewController.swift
//  Locozap
//
//  Created by MAC on 10/20/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

protocol ScreenShotMapViewControllerDelegate {
    func didShareLocation(currentLocation : CLLocationCoordinate2D, image : UIImage);
}

class ScreenShotMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mMapView: MKMapView!
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();
    
    var delegate : ScreenShotMapViewControllerDelegate?;

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: -- Action on click button
    @IBAction func pressActionShareLocation(_ sender: AnyObject) {
        takeSnapshotAnotion(mapView: self.mMapView, coordinate: locationValue) { (uiImage : UIImage?, error : NSError?) in
            if(self.delegate != nil){
                self.delegate?.didShareLocation(currentLocation: self.locationValue, image: uiImage!);
            }
            self.dismiss(animated: true, completion: nil);
        }
    }
    @IBAction func pressActionBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: -- Get location current and map delegate
    func initLocationManager(){
        self.mMapView.delegate = self;
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization();
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startUpdatingLocation();
        }
        self.mMapView.showsUserLocation = true;
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation();
        print(error);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = manager.location!.coordinate;

        let regionLongitude = locationValue.longitude;
        let regionLatitude = locationValue.latitude;
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(regionLatitude) , longitude: Double(regionLongitude));
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        drawPointAnotion(lon: regionLongitude, lat: regionLatitude);
        self.mMapView.setRegion(region, animated: true);
        locationManager.stopUpdatingLocation();
    }
    
    // MARK: -- Screen shot map
    func takeSnapshot(mapView: MKMapView, withCallback: @escaping (UIImage?, NSError?) -> ()) {
        let options = MKMapSnapshotOptions();
        options.region = mapView.region;
        options.size = mapView.frame.size;
        options.scale = UIScreen.main.scale;
        let snapshotter = MKMapSnapshotter(options: options);
        snapshotter.start() { snapshot, error in
            guard snapshot != nil else {
                withCallback(nil, error as NSError?);
                return;
            }
            withCallback(snapshot!.image, nil);
        }
    }
    
    func takeSnapshotAnotion(mapView: MKMapView, coordinate : CLLocationCoordinate2D, withCallback: @escaping (UIImage?, NSError?) -> ()){
        let options = MKMapSnapshotOptions();
        options.region = mapView.region;
        options.size = mapView.frame.size;
        options.scale = UIScreen.main.scale;
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start() {
            snapshot, error in
            guard snapshot != nil else {
                withCallback(nil, error as NSError?);
                return;
            }
            let image = snapshot!.image;
            let annotation : MKPointAnnotation = MKPointAnnotation();
            annotation.coordinate = coordinate;
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation");
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
            image.draw(at : CGPoint(x: 0, y: 0));
            annotationView.drawHierarchy(in: CGRect(x: (snapshot?.point(for: coordinate).x)!, y: (snapshot?.point(for: coordinate).y)! - CGFloat(30), width: annotationView.frame.size.width, height: annotationView.frame.size.height), afterScreenUpdates: true)
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            withCallback(finalImage, nil);
        }
    }
    
    /**
     * Draw icon in map
     *
     */
    func drawPointAnotion(lon:Double, lat:Double){
        // Draw annotation in map kit
        var annotationView:MKPinAnnotationView!;
        var pointAnnoation:MKPointAnnotation!;
        pointAnnoation = MKPointAnnotation();
        pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon);
        annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin");
        self.mMapView.addAnnotation(annotationView.annotation!);
    }
}
