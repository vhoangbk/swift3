/**
 * RegisterStep4ViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class RegisterStep4ViewController: BaseRegisterViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lbCountry: UILabel!
    @IBOutlet weak var viewCountry: UIView!
    
    var fistName : String?;
    var lastName : String?;
    var email : String?;
    var password : String?;
    var countryCode : String?;
    var uiImage : UIImage?
    
    var actionSheetPicker : GKActionSheetPicker?;
    var index : Int = 0;
    
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView();
        initLocationManager();
    }
    
    func initView() {
        
        lbTitle.text = StringUtilities.getLocalizedString("select_country_of_origin", comment: "");
        
        let identity = NSLocale.preferredLanguages.first
        let currentLocale = NSLocale.init(localeIdentifier: identity!);
        
        
        countryCode = "US"
        if ((identity?.components(separatedBy: "-").count)! > 1){
            countryCode = identity?.components(separatedBy: "-")[1];
        }
        
        for i in 0..<Const.arrayCountries.count{
            if (countryCode == Const.arrayCountries[i]){
                index = i;
            }
        }

        let countryName = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: self.countryCode!)
        lbCountry.text = countryName;
        
        imgFlag.image = Utils.getFlagCountry(code: countryCode!);
        
        //picker country
        let tapViewCountry = UITapGestureRecognizer(target: self, action: #selector(RegisterStep4ViewController.showPickerCountry))
        self.viewCountry.addGestureRecognizer(tapViewCountry)
        
    }
    
    override func getRightImage() -> UIImage {
        return UIImage.init(named: "button_done_bg_corner")!;
    }

    override func getRightTitle() -> String {
        return StringUtilities.getLocalizedString("done", comment: "");
    }
    
    override func didPressNext() {
        MBProgressHUD.showAdded(to: self.view, animated: true);
        if (uiImage == nil){
            callApiRegister(avatar: "", avatarSmall: "", avatarMedium: "");
        }else{
            self.uploadImage(image: self.uiImage!);
        }
    }
    
    /*
     * call api add_user
     */
    func callApiRegister(avatar : String, avatarSmall : String, avatarMedium : String) {
        let languageCode = LanguageUtils.getLanguageCode(countryCode: countryCode!);
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue(email!, forKey: Const.KEY_PARAMS_EMAIL);
        params.updateValue(password!, forKey: Const.KEY_PARAMS_PASSWORD);
        params.updateValue(fistName!, forKey: Const.KEY_PARAMS_FIRSTNAME);
        params.updateValue(lastName!, forKey: Const.KEY_PARAMS_LASTNAME);
        params.updateValue(countryCode!, forKey: Const.KEY_PARAMS_COUNTRY);
        params.updateValue(languageCode, forKey: Const.KEY_PARAMS_LANGUAGE);
        params.updateValue(avatar, forKey: Const.KEY_PARAMS_AVATAR);
        params.updateValue(avatarSmall, forKey: Const.KEY_PARAMS_AVATAR_SMALL);
        params.updateValue(avatarMedium, forKey: Const.KEY_PARAMS_AVATAR_MEDIUM);
        params.updateValue(Utils.getDeviceToken(), forKey: Const.KEY_PARAMS_DEVICE_TOKEN);
        
        APIClient.sharedInstance.postRequest(Url: URL_REGISTER, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (success : AnyObject) in
            self.callApiLogin();
            
        }) { (error : AnyObject?) in
            
        }
    }
    
    func uploadImage(image : UIImage) {
        let fileName = Utils.generateFileName();
        APIClient.sharedInstance.uploadImage(image: image, isShowAlert: true, viewController: self, isChat: false, name: fileName, Success: { (success : AnyObject) in

                let responseJson = JSON(success)["data"];
                let paserHelper : ParserHelper = ParserHelper();
                let responseUploadImage = paserHelper.parserUploadImage(data: responseJson);
            
            if (responseUploadImage != nil){
                self.callApiRegister(avatar: responseUploadImage!.url!, avatarSmall: responseUploadImage!.urlSmall!, avatarMedium: responseUploadImage!.urlMedium!);
            }else{
                self.view.makeToast(StringUtilities.getLocalizedString("image_upload_fail", comment: ""), duration: 2.0, position: .center)
            }
            
            
            }, Failure: { (error : AnyObject?) in
                MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func showPickerCountry() {
        
        let currentLocale : NSLocale = NSLocale.current as NSLocale;
        var arrayNameCountries : [GKActionSheetPickerItem] = [GKActionSheetPickerItem]();
        for i in 0..<Const.arrayCountries.count{
            let countryName = currentLocale.displayName(forKey: NSLocale.Key.countryCode, value: Const.arrayCountries[i])
            let item = GKActionSheetPickerItem(title: countryName, value: i)
            arrayNameCountries.append(item!);
        }
        
        actionSheetPicker = GKActionSheetPicker.stringPicker(withItems: arrayNameCountries, selectCallback: { (selected : Any?) in
                self.index = selected as! Int;
                self.countryCode = Const.arrayCountries[self.index];
                self.imgFlag.image = Utils.getFlagCountry(code: self.countryCode!);
                self.lbCountry.text = arrayNameCountries[self.index].title;
            
            }) { 
            
        };
        
        actionSheetPicker?.select(self.toUint(signed: self.index))
        
        actionSheetPicker?.present(on: self.view);
        
    }
    
    /*
     * convet int to uint
     */
    func toUint(signed: Int) -> UInt {
        let unsigned = signed >= 0 ?
            UInt(signed) :
            UInt(signed  - Int.min) + UInt(Int.max) + 1
        
        return unsigned
    }
    
    func callApiLogin(){
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue(email!, forKey: Const.KEY_PARAMS_EMAIL);
        params.updateValue(password!, forKey: Const.KEY_PARAMS_PASSWORD);
        params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        params.updateValue(String(Const.LOGIN_DEFAULT), forKey: Const.KEY_PARAMS_LOGIN_TYPE);
        params.updateValue(Utils.getDeviceToken(), forKey: Const.KEY_PARAMS_DEVICE_TOKEN);
        
        APIClient.sharedInstance.postRequest(Url: URL_LOGIN, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let mainVc = MainViewController();
            let naviVC = UINavigationController(rootViewController: mainVc);
            appDelegate.window?.rootViewController = naviVC;
            appDelegate.window?.makeKeyAndVisible();
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: -- Get location
    func initLocationManager(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = manager.location!.coordinate;
        locationManager.stopUpdatingLocation()
    }
    
}
