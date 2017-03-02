/**
 * PostsActivityStep1ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import DatePickerDialog
import SwiftyJSON

class PostsActivityStep1ViewController: BaseViewController ,CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mViewToolbar: UIView!
    @IBOutlet weak var mViewStatusbar: UIView!
    @IBOutlet weak var mIconTopic: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnNotSpecified: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMetting: UILabel!
    
    // map
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();
    var mCLLocationCoordinate2DResult :CLLocationCoordinate2D!;
    // View
    var colorTabBar : UIColor!;
    var typeTopic : Int!;
    var nameLocation : Dictionary<String, String>! = Dictionary<String, String>();
    var titleTopic : String!;
    var descriptionTopic: String!;
    var typeDateTopic : Int!;
    var valueTypeDateTopic : String!;
    var countryLanguageTopic : String!;
    
    @IBOutlet weak var mMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        NotificationCenter.default.addObserver( self, selector: #selector(PostsActivityStep1ViewController.becomeForeground), name: .UIApplicationDidBecomeActive, object: nil);
        initLocationManager();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func becomeForeground(notification: Notification){
        if(mCLLocationCoordinate2DResult == nil) {
            initLocationManager();
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    // MARK: Init view
    func initView(){
        mViewToolbar.backgroundColor = colorTabBar;
        mViewStatusbar.backgroundColor = colorTabBar;
        mIconTopic.image = Utils.getTopicFormType(typeTopic: typeTopic);
        btnNotSpecified.setTitleColor(colorTabBar, for: UIControlState.normal);
        
        
        // init header
        self.btnContinue.setTitle(StringUtilities.getLocalizedString("activity_post1_btn_post", comment: ""), for: UIControlState.normal);
        self.btnNotSpecified.setTitle(StringUtilities.getLocalizedString("activity_post_map_title2", comment: ""), for: UIControlState.normal);
        lblMetting.text = StringUtilities.getLocalizedString("activity_post_map_title1", comment: "");
        
        
        self.mMapView.delegate = self;
        // Set onclick map
        let uitgr = UITapGestureRecognizer(target: self, action: #selector(addAnnotation));
        uitgr.numberOfTapsRequired = 1
        mMapView.addGestureRecognizer(uitgr);
    }
    
    @IBAction func pressPost(_ sender: Any) {
        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_map_confirm_with_location", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("activity_post1_btn_post", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
            self.callApiGetLocation();
        });
    }
    
    func callApiGetLocation(){
        if (self.mCLLocationCoordinate2DResult == nil) {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_get_location", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                
            });
            return;
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true);
        Utils.getLocation(latitude: self.mCLLocationCoordinate2DResult.latitude, longitude: self.mCLLocationCoordinate2DResult.longitude, language: "en", ViewController: self, completion: { (location, error) -> Void in
            if error != nil {
                MBProgressHUD.hide(for: self.view, animated: true);
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_get_location", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                    
                });
                return
            }
            if(location == nil) {
                MBProgressHUD.hide(for: self.view, animated: true);
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_get_location", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                })
                return;
            }
            
            self.nameLocation.updateValue(location!, forKey: "en");
            
            Utils.getLocation(latitude: self.mCLLocationCoordinate2DResult.latitude, longitude: self.mCLLocationCoordinate2DResult.longitude, language: "ja", ViewController: self, completion: { (location, error) -> Void in
                
                if error != nil {
                    MBProgressHUD.hide(for: self.view, animated: true);
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_get_location", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                        
                    });
                    return
                }
                
                if(location == nil) {
                    MBProgressHUD.hide(for: self.view, animated: true);
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("not_get_location", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                        
                    });
                    return;
                }

                self.nameLocation.updateValue(location!, forKey: "ja");

                self.callApiCreateTopic(isUseLocation: true);
            });
        });
    }

    @IBAction func pressBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true);
    }
    
    @IBAction func pressPostNoLocation(_ sender: Any) {
        Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("post_map_confirm_without_location", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("activity_post1_btn_post", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
            self.callApiCreateTopic(isUseLocation: false);
        });
    }
    
    
    
    // Init map view
    func initLocationManager(){
        Utils.checkLocationIsEnable(viewVC: self, locationManager: self.locationManager);
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startUpdatingLocation();
        }
        self.mMapView.showsUserLocation = true;
    }
    
    // Add anotation click map
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
        drawPointAnotion(latitude: Double(newCoordinates.latitude), longitude: Double(newCoordinates.longitude), isFirstZom: false, titleMarker: StringUtilities.getLocalizedString("pinned_location", comment: ""));
    }
    
    // Draw anotion
    func drawPointAnotion(latitude : Double, longitude : Double, isFirstZom: Bool, titleMarker : String){
        let allAnnotations = self.mMapView.annotations;
        if(allAnnotations.count > 0) {
            self.mMapView.removeAnnotations(allAnnotations);
        }
        //var annotationView:MKPinAnnotationView!;
        var annotation:MKPointAnnotation!;
        annotation = MKPointAnnotation();
        var annotationView:MKPinAnnotationView!;
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        annotation.title = titleMarker;
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin");
        
        self.mMapView.addAnnotation(annotationView.annotation!);
        self.mMapView.selectAnnotation(annotation, animated: true);

        self.cameraZomMapFromLocation(lat: Double(latitude), long: Double(longitude), isFirstZom: isFirstZom);
        self.mCLLocationCoordinate2DResult = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude));
    }
    
    func cameraZomMapFromLocation(lat : Double, long : Double, isFirstZom : Bool = false){
        if(isFirstZom) {
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long);
            let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005));
            self.mMapView.setRegion(region, animated: true);
        } else {
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long);
            let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: self.mMapView.region.span);
            self.mMapView.setRegion(region, animated: true);
        }
    }
    
    
    // MARK: -- Mapp delegate
    
    // Map didFailWithError
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation();
        print(error);
    }
    
     // Map didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = manager.location!.coordinate;
        locationManager.stopUpdatingLocation();
        drawPointAnotion(latitude: locationValue.latitude, longitude: locationValue.longitude, isFirstZom: true, titleMarker: StringUtilities.getLocalizedString("current_location", comment: ""));
    }
    
    /**
     * Click item Annotation
     *
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.setSelected(true, animated: true) ;
    }
    
    // MARK : Call api create topic
    func callApiCreateTopic(isUseLocation : Bool){
        
        var params : Dictionary = Dictionary<String, Any>();
        params.updateValue(Utils.getApiKey(), forKey: Const.KEY_PARAMS_API_KEY);
        params.updateValue(self.titleTopic, forKey: Const.KEY_PARAMS_TOPIC_TITLE);
        params.updateValue(String(self.typeTopic), forKey: Const.KEY_PARAMS_TOPIC_CATEGORY);
        params.updateValue(String(self.typeDateTopic), forKey: Const.KEY_PARAMS_TOPIC_LIMIT_CATEGORY);
        if(self.typeDateTopic == Const.TOPIC_DATE_SPECIFICATION) {
            let secondTime = DateTimeUtils.getSecondFromDate(date: DateTimeUtils.convertStringToDate(strDate: self.valueTypeDateTopic));
            params.updateValue(String(secondTime), forKey: Const.KEY_PARAMS_TOPIC_LIMIT_TIME);
        }
        params.updateValue(self.descriptionTopic, forKey: Const.KEY_PARAMS_TOPIC_CONTENT);
        params.updateValue(countryLanguageTopic, forKey: Const.KEY_PARAMS_TOPIC_LANGUAGE);
        if (isUseLocation == true) {
                params.updateValue(String(self.mCLLocationCoordinate2DResult.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
                params.updateValue(String(self.mCLLocationCoordinate2DResult.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
                params.updateValue(self.nameLocation, forKey: Const.KEY_PARAMS_TOPIC_ADDRESS);
        } else {
            params.updateValue("", forKey: Const.KEY_PARAMS_LONGITUDE);
            params.updateValue("", forKey: Const.KEY_PARAMS_LATITUDE);
            params.updateValue("", forKey: Const.KEY_PARAMS_TOPIC_ADDRESS);
        }
        APIClient.sharedInstance.postRequest(Url: URL_ADD_TOPICS, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (success : AnyObject) in
            MBProgressHUD.hide(for: self.view, animated: true);
            let responseJson = JSON(success);
            let result = responseJson[Const.KEY_RESPONSE_DATA];
            let idTopic = result["id"].stringValue;
            let objHome : ItemHome!;
            let objTopic : Topic!;
            
            if(isUseLocation == true) {
                objTopic = Topic.init(id: idTopic, title: self.titleTopic, content: self.descriptionTopic, category: self.typeTopic, latitude: Double(self.mCLLocationCoordinate2DResult.latitude), longitude: Double(self.mCLLocationCoordinate2DResult.longitude));
                objTopic.address = Address.init(ja: self.nameLocation["ja"]!, en: self.nameLocation["en"]!);
            } else {
                objTopic = Topic.init(id: idTopic, title: self.titleTopic, content: self.descriptionTopic, category: self.typeTopic);
            }
            objHome = ItemHome.init(user: self.mUser!, topic: objTopic);
            
            // Emit new topic to map search
            SocketIOManager.sharedInstance.emitNewTopic(topicId: idTopic);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
            
            let chatGroupVC = ChatGroupViewController();
            chatGroupVC.itemHome = objHome;
            chatGroupVC.fromCreateTopic = true;
            self.navigationController!.pushViewController(chatGroupVC, animated: true);
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true);
        }
    }
    
    func dismissView(){
         dismiss(animated: true, completion: nil);
    }
}
