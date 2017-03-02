/**
 * ScreenShotMapViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

protocol ScreenShotMapViewControllerDelegate {
    func didShareLocation(currentLocation : CLLocationCoordinate2D, image : UIImage);
}

class ScreenShotMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mMapView: MKMapView!
    let locationManager = CLLocationManager();
    var locationValueCurrent:CLLocationCoordinate2D!;
    var locationValue:CLLocationCoordinate2D!;
    var delegate : ScreenShotMapViewControllerDelegate?;
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSendLocation: UIButton!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var titleLocation: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        NotificationCenter.default.addObserver( self, selector: #selector(ScreenShotMapViewController.becomeForeground), name: .UIApplicationDidBecomeActive, object: nil);
        initLocationManager();
        // Set onclick map
        let uitgr = UITapGestureRecognizer(target: self, action: #selector(addAnnotation));
        uitgr.numberOfTapsRequired = 1
        mMapView.addGestureRecognizer(uitgr);
    }
    
    func becomeForeground(notification: Notification){
        if(locationValue == nil) {
            initLocationManager();
        }
    }
    
    func delayWithCallGetUserArround(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

    func initView(){
        btnBack.setTitle(StringUtilities.getLocalizedString("cancel", comment: ""), for: UIControlState.normal);
        btnSendLocation.setTitle(StringUtilities.getLocalizedString("send", comment: ""), for: UIControlState.normal);
        mTitle.text = StringUtilities.getLocalizedString("title_activity_share_current_location", comment: "");
        titleLocation.text = StringUtilities.getLocalizedString("current_location", comment: "");
        self.mMapView.layoutMargins = UIEdgeInsetsMake(60, 0, 0, 13);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: -- Action on click button
    @IBAction func pressActionShareLocation(_ sender: AnyObject) {
        if(locationValue != nil) {
            takeSnapshotAnotion(mapView: self.mMapView, coordinate: locationValue) { (uiImage : UIImage?, error : NSError?) in
                if(self.delegate != nil){
                    self.delegate?.didShareLocation(currentLocation: self.locationValue, image: uiImage!);
                }
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
    @IBAction func pressCurrentLocation(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization();
                
            } else if (CLLocationManager.authorizationStatus() == .denied){
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                });
                
            }else {
                titleLocation.text = StringUtilities.getLocalizedString("current_location", comment: "");
                if(locationValueCurrent != nil){
                    drawPointAnotion(lon: locationValueCurrent.longitude, lat: locationValueCurrent.latitude);
                }
            }
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
            });
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
        locationValueCurrent = manager.location!.coordinate;
        drawPointAnotion(lon: locationValue.longitude, lat: locationValue.latitude);
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
        let allAnnotations = self.mMapView.annotations;
        if(allAnnotations.count > 0) {
            self.mMapView.removeAnnotations(allAnnotations);
        }
        // Draw annotation in map kit
        var annotationView:MKPinAnnotationView!;
        var pointAnnoation:MKPointAnnotation!;
        pointAnnoation = MKPointAnnotation();
        pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon);
        annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin");
        self.mMapView.addAnnotation(annotationView.annotation!);
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon);
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        self.mMapView.setRegion(region, animated: true);
        locationManager.stopUpdatingLocation();
    }
    
    // Add anotation click map
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        titleLocation.text = StringUtilities.getLocalizedString("pinned_location", comment: "");
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            let allAnnotations = self.mMapView.annotations;
            if(allAnnotations.count > 0) {
                self.mMapView.removeAnnotations(allAnnotations);
            }
            if ((placemarks?.count)! > 0) {
                let pm = (placemarks?[0])! as CLPlacemark
                if(pm.thoroughfare != nil && pm.subThoroughfare != nil) {
                    annotation.title = pm.thoroughfare! + ", " + pm.subThoroughfare!
                }
                if(pm.subLocality != nil) {
                    annotation.subtitle = pm.subLocality
                }
            }
            
            annotation.title = "this location";
            self.mMapView.addAnnotation(annotation)
            self.locationValue = CLLocationCoordinate2D(latitude: Double(newCoordinates.latitude), longitude: Double(newCoordinates.longitude));
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.locationValue.latitude, longitude: self.locationValue.longitude);
            let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            self.mMapView.setRegion(region, animated: true);
        });
    }
}
