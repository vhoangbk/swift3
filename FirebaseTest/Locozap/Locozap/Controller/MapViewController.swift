/**
 * MapViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class MapViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D!;
    var mObjectAroundLocationCurrent : ObjectAroundLocationCurrent!;
    var objAround : NSObject!;
    
    
    @IBOutlet weak var mViewInfoAround: UIView!
    @IBOutlet var mViewInfoAccount: UIView!
    @IBOutlet var mViewInfoTopic: UIView!
    @IBOutlet weak var contrainHeightMap: NSLayoutConstraint!
    // View header
    @IBOutlet weak var imgCurrentAvatarUser: SwiftyAvatar!
    @IBOutlet weak var lblShareLocationCurrent: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var mContraintWidthBackgroundShareLocation: NSLayoutConstraint!
    
    
    // View info account
    @IBOutlet weak var mImageAvatar: UIImageView!
    @IBOutlet weak var mImageFlag: UIImageView!
    @IBOutlet weak var mUserName: UILabel!
    @IBOutlet weak var mLblNumberLike: UILabel!
    @IBOutlet weak var mNameLanguage1: UILabel!
    @IBOutlet weak var mRatingbarLanguage1: RatingBar!
    @IBOutlet weak var mNameLanguage2: UILabel!
    @IBOutlet weak var mRatingbarLanguage2: RatingBar!
    @IBOutlet weak var mNameLanguage3: UILabel!
    @IBOutlet weak var mRatingbarLanguage3: RatingBar!
    @IBOutlet weak var mContraintHeightTitle: NSLayoutConstraint!
    
    
    // View info topic
    @IBOutlet weak var mIconCategory: UIImageView!
    @IBOutlet weak var mLblNameCategory: UILabel!
    @IBOutlet weak var mLblDescription: UILabel!
    
    
    @IBOutlet weak var mMapView: MKMapView!
    var isFirstZom = true;
    
    var timer : Timer?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        NotificationCenter.default.addObserver( self, selector: #selector(PostsActivityStep1ViewController.becomeForeground), name: .UIApplicationDidBecomeActive, object: nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func becomeForeground(notification: Notification){
        if(locationValue == nil) {
            initLocationManager();
            delayWithCallGetUserArround(1){
                self.callApiGetAroundUser();
            };
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Listener soket
        listerNewLocationShare();
        listerShareLocationResult();
        listerTopicCreateNew();
    
        initLocationManager();
        isFirstZom = true;
        
        updateUIHeader();
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        mUser = appDelegate.mUser;
        
        // Init View
        if ((mUser?.avatarSmall) != nil) {
            imgCurrentAvatarUser.sd_setImage(with: URL(string: (mUser?.avatarSmall!)!), placeholderImage: UIImage(named: "avatar_no_image"));
        }else{
            imgCurrentAvatarUser.image = UIImage(named: "avatar_no_image");
        }
        
        delayWithCallGetUserArround(1){
            self.callApiGetAroundUser();
        };
        callApiGetUserShareTime();
    }
    
    func delayWithCallGetUserArround(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func initView(){
        lblShareLocationCurrent.text = StringUtilities.getLocalizedString("user_location_shared", comment: "");
        lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_BDBDBD);
        lblHeader.text = StringUtilities.getLocalizedString("header_map", comment: "");
        self.mMapView.layoutMargins = UIEdgeInsetsMake(60, 0, 0, 13);
        self.mMapView.delegate = self;
    }
    
    func updateUIHeader(){
        let widthShareLocation = lblShareLocationCurrent.intrinsicContentSize.width + self.imgCurrentAvatarUser.bounds.width + 10;
        self.mContraintWidthBackgroundShareLocation.constant = widthShareLocation;
        
        if (DeviceUtil.hardware() == .IPHONE_5 || DeviceUtil.hardware() == .IPHONE_5C
            || DeviceUtil.hardware() == .IPHONE_5S || DeviceUtil.hardware() == .IPHONE_SE){
            lblShareLocationCurrent.font = UIFont.systemFont(ofSize: 14);
            self.mContraintWidthBackgroundShareLocation.constant = widthShareLocation - 10;
        }
    }
    
    @IBAction func pressCurrentLocation(_ sender: Any) {
        if(locationValue != nil) {
            self.cameraZomMapFromLocation(lat: locationValue.latitude, long: locationValue.longitude);
        } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
            });
        }
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
    
    // MARK: -- Info user or topic bottom map
    // View user info
    func initViewInfoAccount(user : User){
        if (mViewInfoAround.isHidden) {
            mViewInfoAround.isHidden = false;
        }
        mViewInfoAround.subviews.forEach { $0.removeFromSuperview() };
        mViewInfoAccount.frame = CGRect(x: mViewInfoAccount.frame.origin.x, y: mViewInfoAccount.frame.origin.y, width: UIScreen.main.bounds.width, height: mViewInfoAccount.frame.size.height);
        mViewInfoAround.addSubview(mViewInfoAccount);
        self.updateViewLanguage(user: user);
        if(user.avatarSmall != nil) {
            mImageAvatar.sd_setImage(with: URL(string: user.avatarSmall!), placeholderImage: UIImage(named: "avatar_no_image"));
        }
        if(user.codeCountry != nil){
            mImageFlag.image = Utils.getFlagCountry(code: user.codeCountry!);
        }
        mUserName.text = Utils.getFullName(user: user);
        if(user.like != nil) {
            mLblNumberLike.text = String((user.like)!);
        } else {
            mLblNumberLike.text = "0";
        }
        self.cameraZomMapFromLocation(lat: user.latitude!, long: user.longitude!);
    }
    
    @IBAction func pressShareLocation(_ sender: Any) {
        if(Utils.getApiKey() == ""){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_set_it_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                
                let loginVC = LoginViewController();
                self.navigationController?.pushViewController(loginVC, animated: true);
                
            });
            return;
        }
         if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization();
            } else {
                if(locationValue != nil) {
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("confirm_share_location", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                        self.shareLocation(latitude: self.locationValue.latitude, lontitude: self.locationValue.longitude);
                    });
                } else {
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                        
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                    });
                }
            }
         } else {
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: { (UIAlertAction) in
                
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
            });
         }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(timer != nil) {
            timer?.invalidate();
        }
        
        MBProgressHUD.hide(for: self.view, animated: true);
        SocketIOManager.sharedInstance.offServerShareLocationResult();
        SocketIOManager.sharedInstance.offNewShareUser();
        SocketIOManager.sharedInstance.offNewTopicCreateShareMap();
    }
    
    func updateViewLanguage(user : User){
        mNameLanguage1.isHidden = false;
        mRatingbarLanguage1.isHidden = false;
        mNameLanguage2.isHidden = true;
        mRatingbarLanguage2.isHidden = true;
        mNameLanguage3.isHidden = true;
        mRatingbarLanguage3.isHidden = true;
        if (user.language != nil) {
            if((user.language?.count)! > 2) {
                mContraintHeightTitle.constant = 16.5;
            } else {
                mContraintHeightTitle.constant = 25;
            }
            for i in 0..<(user.language?.count)! {
                let lang = user.language?[i];
                if ( i == 0 ){
                    mRatingbarLanguage1.rating = CGFloat((lang?.level)!);
                    if(lang?.codeLanguage != nil) {
                        mNameLanguage1.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                    }
                }
                
                if ( i == 1 ){
                    mRatingbarLanguage2.rating = CGFloat((lang?.level)!);
                    if(lang?.codeLanguage != nil) {
                        mNameLanguage2.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                    }
                    mNameLanguage2.isHidden = false;
                    mRatingbarLanguage2.isHidden = false;
                }
                
                if ( i == 2 ){
                    mRatingbarLanguage3.rating = CGFloat((lang?.level)!);
                    if(lang?.codeLanguage != nil) {
                        mNameLanguage3.text = LanguageUtils.getLanguageNameFromLanguageCode(languageCode: (lang?.codeLanguage)!);
                    }
                    mNameLanguage3.isHidden = false;
                    mRatingbarLanguage3.isHidden = false;
                }
            }
        }
        
    }
    
    // View topic info
    func initViewInfoTopic(topic : Topic){
        if (mViewInfoAround.isHidden) {
            mViewInfoAround.isHidden = false;
        }
        mViewInfoAround.subviews.forEach { $0.removeFromSuperview() };
        mViewInfoTopic.frame = CGRect(x: mViewInfoTopic.frame.origin.x, y: mViewInfoTopic.frame.origin.y, width: UIScreen.main.bounds.width, height: mViewInfoTopic.frame.size.height);
        mViewInfoAround.addSubview(mViewInfoTopic);
        mIconCategory.image = Utils.getTopicFormType(typeTopic: topic.category!);
        mLblNameCategory.text = topic.title;
        mLblNameCategory.textColor = Utils.getColorFromTypeTopic(typeCategory: topic.category!);
        mLblDescription.text = topic.content;
        self.cameraZomMapFromLocation(lat: topic.latitude!, long: topic.longitude!);
    }
    
    @IBAction func pressHistoryTopic(_ sender: Any) {
		if (mUser == nil){
			Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_set_it_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
				
				let loginVC = LoginViewController();
				self.navigationController?.pushViewController(loginVC, animated: true);
				
			})
			return;
		}
        let historyVC = HistoryViewController();
        self.navigationController?.pushViewController(historyVC, animated: true);
    }

    // MARK: -- onClick view
    @IBAction func didPressUserAround(_ sender: AnyObject) {
        if (self.objAround != nil) {
            if(self.objAround .isKind(of: User.self)){
                let userProfileViewController = UserProfileViewController();
                userProfileViewController.userAround = self.objAround as! User;
                self.navigationController?.pushViewController(userProfileViewController, animated: true);
            } else if (self.objAround .isKind(of: Topic.self)){
                let mTopic : Topic = self.objAround as! Topic;
                let mItemHome : ItemHome = ItemHome.init(user: mTopic.userCreate!, topic: mTopic);
                let chatVC = ChatGroupViewController();
                chatVC.itemHome = mItemHome;
                self.navigationController?.pushViewController(chatVC, animated: true);
            }
        }
    }
    
    // MARK: -- Get location current
    func initLocationManager(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization();
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startUpdatingLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation();
        print(error);
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = manager.location!.coordinate;
        if(isFirstZom) {
            self.cameraZomMapFromLocation(lat: Double(locationValue.latitude), long: Double(locationValue.longitude), isFirstZom: true);
        }
        isFirstZom = false;
        locationManager.stopUpdatingLocation();
    }

    // MARK: -- Delegate map view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseIdentifier = "mCustomPointAnnotation";
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        let customView = Bundle.main.loadNibNamed("MyMKAnnotationView", owner: self, options: nil)?.last as! MyMKAnnotationView;
        v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier);
        // Annotion custome
        if (annotation .isKind(of: CustomPointAnnotation.self)) {
            let customPointAnnotation = annotation as! CustomPointAnnotation;
            if(customPointAnnotation.obj .isKind(of: User.self)){
                // Add view user
                v?.subviews.forEach { $0.removeFromSuperview() };
                v?.addSubview(customView)
                v!.canShowCallout = true;
                
                let user = customPointAnnotation.obj as! User;
                if(user.avatarSmall != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: user.avatarSmall!), placeholderImage: UIImage(named:"avatar_no_image"));
                } else if(user.avatarMedium != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: user.avatarMedium!), placeholderImage: UIImage(named:"avatar_no_image"));
                }  else if(user.avatar != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: user.avatar!), placeholderImage: UIImage(named:"avatar_no_image"));
                }
                customView.frame = CGRect.init(x: -10, y: 0, width: customView.frame.size.width - 5, height: customView.frame.size.height - 5);
                customView.imgAvatar.frame = CGRect.init(x: -10, y: 0, width: customView.frame.size.width - 15, height: customView.frame.size.height - 15);
                customView.imgFlag.image = Utils.getFlagCountry(code: user.codeCountry!);
                customView.imgFlag.isHidden = false;
            } else if(customPointAnnotation.obj .isKind(of: Topic.self)){
                // view topic
                let customView1 = Bundle.main.loadNibNamed("MyMKAnnotationViewCategory", owner: self, options: nil)?.last as! MyMKAnnotationViewCategory;
                // Add view user
                v?.subviews.forEach { $0.removeFromSuperview() };
                v?.addSubview(customView1)
                v!.canShowCallout = true;
                
                customView1.frame = CGRect.init(x: -15, y: 0, width: customView1.frame.size.width, height: customView1.frame.size.height);
                let topic = customPointAnnotation.obj as! Topic;
                if(topic.category != nil){
                    customView1.imgCategory.image = Utils.getTopicWhiteBackgroundFormType(typeTopic: topic.category!);
                }
            }
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            mUser = appDelegate.mUser;
            if(mUser != nil){
                v?.subviews.forEach { $0.removeFromSuperview() };
                v?.addSubview(customView);
                v!.canShowCallout = true;
                if(mUser?.avatarSmall != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: (mUser?.avatarSmall)!), placeholderImage: UIImage(named:"avatar_no_image"));
                } else if(mUser?.avatarMedium != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: (mUser?.avatarMedium)!), placeholderImage: UIImage(named:"avatar_no_image"));
                }  else if(mUser?.avatar != nil) {
                    customView.imgAvatar.sd_setImage(with: URL.init(string: (mUser?.avatar)!), placeholderImage: UIImage(named:"avatar_no_image"));
                }
                customView.frame = CGRect.init(x: 0, y: 0, width: customView.frame.size.width - 5, height: customView.frame.size.height - 5);
                customView.imgAvatar.frame = CGRect.init(x: 0, y: 0, width: customView.frame.size.width - 5, height: customView.frame.size.height - 5);
                customView.imgFlag.image = Utils.getFlagCountry(code: (mUser?.codeCountry)!);
                customView.imgFlag.isHidden = false;
            }
        }
        v!.frame = (CGRect(x: 0, y: 0, width: customView.frame.size.width, height: customView.frame.size.height));
        return v;
    }

    /**
     * Did selected item Annotation
     *
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if((view.annotation?.isKind(of: CustomPointAnnotation.self))!){
            let item = view.annotation as! CustomPointAnnotation;
            if (item.obj.isKind(of: User.self)) {
                let user = item.obj as! User;
                if(mUser?.id != nil && user.id == mUser?.id){
                } else {
                    //self.contrainHeightMap.constant = 84 + 49;
                    objAround = item.obj;
                    self.initViewInfoAccount(user: item.obj as! User);
                }
            } else if (item.obj.isKind(of: Topic.self)) {
                //self.contrainHeightMap.constant = 84 + 49;
                objAround = item.obj;
                self.initViewInfoTopic(topic: item.obj as! Topic);
            }
        } else {
            self.cameraZomMapFromLocation(lat: Double(locationValue.latitude), long: Double(locationValue.longitude));
        }
    }
    
    
    /**
     * Draw icon in map
     *
     */
    func drawPointAnotionUser(objUser : User){
        
        // Draw annotation in map kit
        var lon:Double!;
        var lat:Double!;
        var annotationView:MKPinAnnotationView!;
        var pointAnnoation:CustomPointAnnotation!;
        lon = Double(objUser.longitude!);
        lat = Double(objUser.latitude!);
        pointAnnoation = CustomPointAnnotation();
        pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon);
        pointAnnoation.title = objUser.fistName!;
//        pointAnnoation.subtitle = objUser.lastName!;
        pointAnnoation.obj = objUser;
        annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin");
        self.mMapView.addAnnotation(annotationView.annotation!);
    }
    
    func drawPointAnotionCategory(objTopic : Topic){
        // Draw annotation in map kit
        var lon:Double!;
        var lat:Double!;
        var annotationView:MKPinAnnotationView!;
        var pointAnnoation:CustomPointAnnotation!;
        lon = Double(objTopic.longitude!);
        lat = Double(objTopic.latitude!);
        pointAnnoation = CustomPointAnnotation();
        pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon);
        pointAnnoation.title = objTopic.title!;
//        pointAnnoation.subtitle = objTopic.content!;
        pointAnnoation.obj = objTopic;
        annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin");
        self.mMapView.addAnnotation(annotationView.annotation!);
    }
    
    //MARK: -- Call api
    
    func callApiGetAroundUser(){
        MBProgressHUD.hide(for: self.view, animated: true);
        MBProgressHUD.showAdded(to: self.view, animated: true);
        // Remove all anotation
        mViewInfoAround.isHidden = true;
        self.contrainHeightMap.constant = 49;
        let allAnnotations = self.mMapView.annotations;
        if(allAnnotations.count > 0) {
            self.mMapView.removeAnnotations(allAnnotations);
        }
        
        var params : Dictionary = Dictionary<String, String>();
        if(locationValue != nil) {
            params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
            params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        } else {
            MBProgressHUD.hide(for: self.view, animated: true);
            return;
        }
        if(mUser != nil && mUser?.apiKey != nil){
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        }
        
        APIClient.sharedInstance.postRequest(Url: URL_USER_AROUND, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (response : AnyObject) in
            MBProgressHUD.hide(for: self.view, animated: true);
            let responseJson = JSON(response);
            let paserHelper : ParserHelper = ParserHelper();
            self.mObjectAroundLocationCurrent = paserHelper.parserUserAround(data: responseJson["data"]);
            let arrayUser : [User] = self.mObjectAroundLocationCurrent.arrayUser;
            let arrayTopic : [Topic] = self.mObjectAroundLocationCurrent.arrayTopic;
            for objUser in arrayUser {
                self.drawPointAnotionUser(objUser: objUser);
            }
            for objTopic in arrayTopic {
                self.drawPointAnotionCategory(objTopic: objTopic);
            }
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true);
        }
    }
    
    func callApiGetUserShareTime(){
        var params : Dictionary = Dictionary<String, String>();
        if(mUser?.apiKey != nil){
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        } else {
            return;
        }
        APIClient.sharedInstance.postRequest(Url: URL_USER_LOCATION_SHARE_TIME, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (response : AnyObject) in
            let responseJson = JSON(response)["data"];
            if(responseJson["expired_time_location"] != JSON.null) {
                let longTime : Int = responseJson["expired_time_location"].intValue;
                self.initTimer(timeInterval: Double(longTime));
            }
        }) { (error : AnyObject?) in
            
        }
    }
    
    func initTimer(timeInterval : Double) {
        if (timer != nil){
            timer!.invalidate();
            timer = nil;
        }
        if(timeInterval > 0){
            self.mMapView.showsUserLocation = true;
            self.lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_FED303);
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(MapViewController.resetShareLocation), userInfo: nil, repeats: true);
        } else {
            lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_BDBDBD);
            self.mMapView.showsUserLocation = false;
        }
    }
    
    func resetShareLocation(){
        self.navigationController!.view.makeToast(StringUtilities.getLocalizedString("location_stop_shared", comment: ""));
        self.lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_BDBDBD);
    }
    
    // MARK: socket
    func shareLocation(latitude: Double, lontitude: Double){
        SocketIOManager.sharedInstance.actionShareLocation(latitude: latitude, lontitude: lontitude);
    }
    
    func listerNewLocationShare(){
        SocketIOManager.sharedInstance.onNewShareUser { (data : Any) in
            print("[MapViewController] onNewShareUser \(data)")
            let result = JSON(data);
            let paserHelper : ParserHelper = ParserHelper();
            let newUser : User = paserHelper.pareserModel(data: result);
            self.removerAnnotationFromObject(obj: newUser)
        }
    }
    
    func listerShareLocationResult(){
        SocketIOManager.sharedInstance.onServerShareLocationResult { (data : Any) in
            print("[MapViewController] onServerShareLocationResult \(data)")
            let result = JSON(data);
            if(result["success"] != JSON.null){
                if(result["success"].boolValue){
                    let longTime : Int = result["expired_time_location"].intValue;
                    self.initTimer(timeInterval: Double(longTime));
                    self.lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_FED303);
                    self.mMapView.showsUserLocation = true;
                    self.navigationController!.view.makeToast(StringUtilities.getLocalizedString("location_shared", comment: ""));
                } else {
                    self.mMapView.showsUserLocation = false;
                    self.lblShareLocationCurrent.textColor = UIColor(netHex: Const.COLOR_BDBDBD);
                }
            }
        }
    }
    
    func listerTopicCreateNew(){
        SocketIOManager.sharedInstance.onNewTopicCreateShareMap { (data : Any) in
            print("[MapViewController] onNewTopicCreateShareMap \(data)")
            let result = JSON(data);
            let paserHelper : ParserHelper = ParserHelper();
            let newTopic : Topic = paserHelper.pareserModel(data: result);
            self.removerAnnotationFromObject(obj: newTopic)
        }
    }
    
    func removerAnnotationFromObject(obj : AnyObject){
        var flagIsUser = false;
        var objUser : User!;
        var objTopic : Topic!;
        if(obj.isKind(of: User.self)){
            flagIsUser = true;
            objUser = obj as! User;
        } else {
            flagIsUser = false;
            objTopic = obj as! Topic;
        }
        let allAnnotations = self.mMapView.annotations;
        var flagAdd = true;
        // Start for
        for annotation in allAnnotations {
            // Start annotation is CustomPointAnnotation
            if(annotation.isKind(of: CustomPointAnnotation.self)){
                let customPointAnnotation = annotation as! CustomPointAnnotation;
                let item = customPointAnnotation.obj;
                // Start item != nil
                if (item != nil) {
                    // Start check is user or topic
                    if (flagIsUser) {
                        if((item?.isKind(of: User.self))!){
                            let userMap = item as! User;
                            if(userMap.id == objUser.id) {
                                self.mMapView.removeAnnotation(annotation);
                                self.drawPointAnotionUser(objUser: objUser);
                                flagAdd = false;
                                break;
                            }
                        }
                    } else {
                        // Check topic annotation
                        if((item?.isKind(of: Topic.self))!){
                            let topicMap = item as! Topic;
                            if(topicMap.id == objTopic.id) {
                                self.mMapView.removeAnnotation(annotation);
                                self.drawPointAnotionCategory(objTopic: objTopic);
                                flagAdd = false;
                                break;
                            }
                        }
                    }
                    // End check is user or topic
                }
                // End item != nil
            }
            // End annotation is CustomPointAnnotation
        }
        // End for
        
        if(flagAdd){
            if(flagIsUser){
                self.drawPointAnotionUser(objUser: objUser);
            } else {
                self.drawPointAnotionCategory(objTopic: objTopic);
            }
        }
    }
}
