//
//  MapViewController.swift
//  Locozap
//
//  Created by Hoang Nguyen on 10/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class MapViewController: BaseViewController, RatingBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();
    var arrayData : [User] = [User]();
    var userAround : User = User.init();
    // View info
    @IBOutlet weak var mImageAvatar: UIImageView!
    @IBOutlet weak var mImageFlag: UIImageView!
    @IBOutlet weak var mUserName: UILabel!
    @IBOutlet weak var mLblNumberLike: UILabel!
    
    @IBOutlet weak var mMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager();
        callApiGetAroundUser();
    }
    
    // MARK: -- Info user onclick
    func initViewInfoAccount(user : User){
        mImageAvatar.sd_setImage(with: URL(string: user.avatar!), placeholderImage: UIImage(named: "avatar_no_image"));
        mUserName.text = user.fistName! + user.lastName!;
        mLblNumberLike.text = "134";
        
        // Camera zoom user selected
        let regionLongitude = user.longitude;
        let regionLatitude = user.latitude;
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(regionLatitude!)! , longitude: Double(regionLongitude!)!);
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        self.mMapView.setRegion(region, animated: true);
        self.userAround = user;
    }
    
    func initViewInfoAccount(arrayUser : [User]){
        for user in arrayUser {
            if (user.longitude != "0") {
                self.initViewInfoAccount(user: user);
            }
        }
    }
    
    // MARK: -- onClick view

    @IBAction func didPressUserAround(_ sender: AnyObject) {
        if (userAround.id != nil) {
            let locationAcountInfo = LocationAccountInfoViewController();
            locationAcountInfo.userAround = self.userAround;
            self.navigationController?.pushViewController(locationAcountInfo, animated: true);
        }
    }
    
    
    // MARK: -- Rating bar delegate
    internal func ratingDidChange(ratingBar: RatingBar, rating: CGFloat) {
        
    }
    
    // MARK: -- Get location current
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
        print("locations = \(locationValue.latitude) \(locationValue.longitude)");
        locationManager.stopUpdatingLocation();
    }

    // MARK: -- Delegate map view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "myPin";
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier);
            v!.canShowCallout = true;
        }
        else {
            v!.annotation = annotation;
        }
        let customPointAnnotation = annotation as! CustomPointAnnotation;
        if (customPointAnnotation.pinCustomImageName.hasPrefix("http") == true) {
            let url = NSURL(string:customPointAnnotation.pinCustomImageName);
            let data = NSData(contentsOf:url! as URL);
            if ((data?.length)! > 0) {
                v!.image =  UIImage(data:data! as Data);
            } else {
                v!.image = UIImage(named:"avatar_no_image");
            }
        } else {
            v!.image = UIImage(named:"avatar_no_image");
        }
        return v;
    }

    /**
     * Did selected item Annotation
     *
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let item = view.annotation as! CustomPointAnnotation;
        self.initViewInfoAccount(user: item.user);
    }
    
    /**
     * Draw icon in map
     *
     */
    func drawPointAnotion(arrayData:[User]){
        if arrayData.count == 0{
            return;
        }
        // Draw annotation in map kit
        var lon:Double!;
        var lat:Double!;
        var annotationView:MKPinAnnotationView!;
        var pointAnnoation:CustomPointAnnotation!;
        for item in arrayData{
            lon = Double(item.longitude!);
            lat = Double(item.latitude!);
            pointAnnoation = CustomPointAnnotation();
            pointAnnoation.pinCustomImageName = item.avatar;
            pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon);
            pointAnnoation.title = item.fistName!;
            pointAnnoation.subtitle = item.lastName!;
            pointAnnoation.user = item;
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin");
            self.mMapView.addAnnotation(annotationView.annotation!);
        }
    }
    
    //MARK: -- Call api
    
    func callApiGetAroundUser(){
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue((mUser?.token)!, forKey: Const.KEY_PARAMS_TOKEN);
        params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        APIClient.sharedInstance.postRequest(Url: URL_USER_AROUND, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (response : AnyObject) in
            let responseJson = JSON(response);
            let listUserAround = responseJson["data"].arrayValue;
            let paserHelper : ParserHelper = ParserHelper();
            for itemTopic in listUserAround{
                let user = paserHelper.parserUser(data: itemTopic);
                self.arrayData.append(user);
            }
            // Camera zoom first user
            self.initViewInfoAccount(arrayUser : self.arrayData);
            // Draw anotion marker
            self.drawPointAnotion(arrayData: self.arrayData);
        }) { (error : AnyObject?) in
            
        }
    }
}
