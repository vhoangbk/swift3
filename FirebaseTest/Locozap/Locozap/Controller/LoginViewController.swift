/**
 * LoginViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SocketIO
import TTTAttributedLabel
import FacebookLogin
import FacebookCore
import SwiftyJSON

class LoginViewController: BaseViewController, TTTAttributedLabelDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mBtnRegister: UIButton!
    @IBOutlet weak var mBtnLoginWithFacebook: UIButton!
    @IBOutlet weak var btnLogin: LocalizedButton!
    @IBOutlet weak var lbClose: LocalizedButton!
    @IBOutlet weak var viewTerms: UIView!
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();
    
    var mAccessToken : AccessToken?;
    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        initLocationManager();
        
        btnLogin.layer.cornerRadius = CGFloat(5)
        
        UIApplication.shared.applicationIconBadgeNumber = 0;
        UIApplication.shared.cancelAllLocalNotifications();
    }
	
	override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
        SocketIOManager.sharedInstance.offListenerGlobal();
        Utils.setBadgeTabber(number: 0);
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView(){
        let strBtnLoginWithFacebook = StringUtilities.getLocalizedString("account_facebook", comment: "");
        let strBtnRegister = StringUtilities.getLocalizedString("account_creation", comment: "");
        let strBtnLoginAcount = StringUtilities.getLocalizedString("login", comment: "");
        
        mBtnRegister.setTitle(strBtnRegister, for: UIControlState.normal);
        mBtnLoginWithFacebook.setTitle(strBtnLoginWithFacebook, for: UIControlState.normal);
        btnLogin.setTitle(strBtnLoginAcount, for: UIControlState.normal);
        
        lbClose.setTitle(StringUtilities.getLocalizedString("close", comment: ""), for: .normal);
        
        let mLabel = Utils.createLabelTermsPolicy(delegate: self, urlTerms: Const.URL_TERM + Utils.getLanguageCode(), urlPolicy: Const.URL_PRIVACY + Utils.getLanguageCode());
        self.viewTerms.addSubview(mLabel);
        
        mLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: self.viewTerms.frame.height)
        
        if (AccessToken.current != nil) {
            mAccessToken = AccessToken.current;
        }
    }
    
    //MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = WebViewViewController();
        vc.url = url;
        if (url.absoluteString.contains(Const.URL_TERM)){
            vc.isShowNaviWeb = true;
        }
        self.navigationController?.pushViewController(vc, animated: true);
    }
        

    @IBAction func pressActionLogin(_ sender: AnyObject) {
        let loginVC = LoginAccountViewController()
        let naviVC = UINavigationController(rootViewController: loginVC);
        present(naviVC, animated: true, completion: nil);
    }
    
    @IBAction func pressActionLoginFacebook(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true);
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email, .custom("user_location"), .custom("user_hometown")], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                MBProgressHUD.hide(for: self.view, animated: true);
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("login_facebook_fail", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                print(error);
                break;
            case .cancelled:
                MBProgressHUD.hide(for: self.view, animated: true);
                print("Cancel login");
                break;
            case .success( _, _, _):
                self.facebookGraphRequest();
                break;
            }
        }
    }
    
    func facebookGraphRequest(){
        if (AccessToken.current != nil) {
            mAccessToken = AccessToken.current;
        }
        var params = ["fields" : "id, email, name, first_name, last_name, location, locale, birthday, gender, hometown"];
        if(Utils.isJapanese()) {
            params.updateValue("ja_JP", forKey: "locale");
        } else {
            params.updateValue("en_US", forKey: "locale");
        }
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            switch requestResult {
            case .failed(let error):
                MBProgressHUD.hide(for: self.view, animated: true);
                print("Error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    self.callApiLogin(dictGraphResponse: responseDictionary)
                }
            }
        }
    }
    
    @IBAction func pressActionRegistrer(_ sender: AnyObject) {
        let resgisVC = RegisterStep1ViewController()
        let naviVC = UINavigationController(rootViewController: resgisVC);
        present(naviVC, animated: true, completion: nil);
    }
    
    @IBAction func pressClose(_ sender: AnyObject) {
        if ((self.navigationController?.viewControllers.count)! > 1){
            self.navigationController!.popViewController(animated: true);
        }else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let mainVc = MainViewController();
            let naviVC = UINavigationController(rootViewController: mainVc);
            appDelegate.window?.rootViewController = naviVC;
            appDelegate.window?.makeKeyAndVisible();
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error);
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = manager.location!.coordinate;
        print("locations = \(locationValue.latitude) \(locationValue.longitude)");
        locationManager.stopUpdatingLocation()
    }
    
    func callApiLogin(dictGraphResponse : [String : Any]){
//        let valueParam : (firstName: String, lastName: String, idFacebook: String, countryCode: String, languageCode : String, avatar : String, gender : String, birthday : String, address : String, email : String) = getParamFromDict(dictGraphResponse: dictGraphResponse);
        
        let firstName = dictGraphResponse["first_name"] as! String;
        let lastName = dictGraphResponse["last_name"] as! String;
        let idFacebook = dictGraphResponse["id"] as! String;
        var strLocale : String = "en_US";
        if let locale = dictGraphResponse["locale"] {
            strLocale = locale as! String;
        }
        let arrayLocale = strLocale.components(separatedBy: "_");
        var languageCode = "en";
        var countryCode = "";
        if(arrayLocale.count > 1){
            languageCode = arrayLocale[0];
            //            countryCode = arrayLocale[1];
        }
        
        var gender : String = "";
        if let gen = dictGraphResponse["gender"] {
            gender = gen as! String;
        }
        
        var birthday : String = "";
        if let bir = dictGraphResponse["birthday"] {
            birthday = bir as! String;
        }
        
        var email : String = "";
        if let ema = dictGraphResponse["email"] {
            email = ema as! String;
        }
        
        let avatar = "https://graph.facebook.com/" + idFacebook + "/picture?type=";
        var address : String = "";
        
        var params : Dictionary = Dictionary<String, Any>();
        params.updateValue(idFacebook, forKey: Const.KEY_PARAMS_FACEBOOK_ID);
        params.updateValue(email, forKey: Const.KEY_PARAMS_EMAIL);
        params.updateValue(idFacebook+"&W68a2Ej", forKey: Const.KEY_PARAMS_PASSWORD);
        
        
        params.updateValue(firstName, forKey: Const.KEY_PARAMS_FIRSTNAME);
        params.updateValue(lastName, forKey: Const.KEY_PARAMS_LASTNAME);
        params.updateValue(countryCode, forKey: Const.KEY_PARAMS_COUNTRY);
        params.updateValue(languageCode, forKey: Const.KEY_PARAMS_LANGUAGE);
        params.updateValue(avatar + TypeAvatar.Large.rawValue, forKey: Const.KEY_PARAMS_AVATAR);
        params.updateValue(avatar + TypeAvatar.Small.rawValue, forKey: Const.KEY_PARAMS_AVATAR_SMALL);
        params.updateValue(avatar + TypeAvatar.Medium.rawValue, forKey: Const.KEY_PARAMS_AVATAR_MEDIUM);
        params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        params.updateValue(String(Const.LOGIN_FACEBOOK), forKey: Const.KEY_PARAMS_LOGIN_TYPE);
        params.updateValue(Utils.getDeviceToken(), forKey: Const.KEY_PARAMS_DEVICE_TOKEN);
        
        var birth : Int = 0;
        if (birthday != ""){
            let birthDay = DateTimeUtils.convertStringToDate(strDate: birthday, formatterDate: "MM/dd/yyyy")
            birth = Int(birthDay.timeIntervalSince1970);
            IgaworksCore.setAge(Int32(birthDay.age))
        }
        params.updateValue(Utils.getSexCode(gender: gender), forKey: Const.KEY_PARAMS_SEX);
        if Utils.getSexCode(gender: gender) == Const.SEXCODE_MALE {
            IgaworksCore.setGender(IgaworksCoreGenderMale)
        } else if Utils.getSexCode(gender: gender) == Const.SEXCODE_FEMALE {
            IgaworksCore.setGender(IgaworksCoreGenderFemale)
        }
        if (birth != 0){
            params.updateValue(birth, forKey: Const.KEY_PARAMS_BIRTHDAY);
        }
        
        params.updateValue(address, forKey: Const.KEY_PARAMS_ADDRESS);
        

        var idHomeTown : String = "";
        if let add = dictGraphResponse["location"] {
            address = (add as! Dictionary)["name"]!;
        }
        
        if let homeTown = dictGraphResponse["hometown"] {
            idHomeTown = (homeTown as! Dictionary)["id"]!;
            APIClient.sharedInstance.getData(Url: APIClient.sharedInstance.createUrlFacebookHomeTown(homeTownId: idHomeTown, accessToken: (mAccessToken?.authenticationToken)!), ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (success) in
                let response = JSON(success);
                var dictLocation = response["location"];
                var countryName = dictLocation["country"];
                if(countryName != nil) {
                    countryCode = LanguageUtils.getCountryCodeByContryNameFB(countryName: countryName.stringValue);
                    params.updateValue(address, forKey: Const.KEY_PARAMS_ADDRESS);
                    params.updateValue(countryCode, forKey: Const.KEY_PARAMS_COUNTRY);
                }
                self.callApiLoginFacebook(params: params  as [String : AnyObject]);
            }, Failure: { (error) in
                //
                self.callApiLoginFacebook(params: params  as [String : AnyObject]);
            });
        } else {
            callApiLoginFacebook(params: params  as [String : AnyObject]);
        }
    }

    func callApiLoginFacebook(params : [String : AnyObject]){
        APIClient.sharedInstance.postRequest(Url: URL_LOGIN, Parameters: params, ViewController: self, ShowProgress: false, ShowAlert: true, Success: { (success : AnyObject) in
            MBProgressHUD.hide(for: self.view, animated: true);
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let mainVc = MainViewController();
            let naviVC = UINavigationController(rootViewController: mainVc);
            appDelegate.window?.rootViewController = naviVC;
            appDelegate.window?.makeKeyAndVisible();
            
        }) { (error : AnyObject?) in
            MBProgressHUD.hide(for: self.view, animated: true);
        }
    }
}
