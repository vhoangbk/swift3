/**
 * Utils
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import Foundation
import SwiftyJSON
import SystemConfiguration
import Alamofire
import TTTAttributedLabel
import GoogleMobileAds

class Utils: NSObject {

    class func corner(_ view : UIView, roundingCorner : UIRectCorner, radius : CGFloat) {
        let maskPath : UIBezierPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners:roundingCorner, cornerRadii: CGSize(width: radius, height: radius));
        let maskLayer : CAShapeLayer = CAShapeLayer();
        maskLayer.path = maskPath.cgPath;
        view.layer.mask = maskLayer;
    }
    
    @available(iOS 8.0, *)
    class func showAlertWithTitle(_ title: String!, message: String, titleButtonClose : String, titleButtonOk : String, viewController: UIViewController, actionOK: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButtonOk, style: .default, handler: actionOK);
        alert.addAction(action)
        if(!titleButtonClose.isEmpty){
            let actionCancel = UIAlertAction(title: titleButtonClose, style: .cancel, handler: nil);
            alert.addAction(actionCancel);
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    class func convertDictionaryToJSonString(_ dic : Dictionary<String, AnyObject>) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            let theJSONText = String(data: jsonData,
                                     encoding: String.Encoding.ascii)
            return theJSONText;
        } catch let error as NSError {
            print(error)
        }
        return nil;
    }
    
    class func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

    class func setInfoAccount(infoAccount : AnyObject?){
        UserDefaults.standard.set(infoAccount, forKey: Const.USER_DEFAULT_KEY_INFO_ACCOUNT);
    }
    
    class func getInfoAccount() -> AnyObject? {
        return UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_INFO_ACCOUNT) as AnyObject?;
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    

    class func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: Date());
    }
    
    class func getFlagCountry(code : String) -> UIImage {
        let image = UIImage(named: "flag_"+code);
        if (image != nil){
            return image!;
        }
        return UIImage(named: "flag_noimage")!;
    }
    
    // Create topic
    class func getTopicFormType(typeTopic : Int) -> UIImage{
        var imageResult : UIImage!;
        if (typeTopic == Const.TOPIC_CATEGORY_FOOD) {
            imageResult = UIImage(named: "ic_food");
        } else if (typeTopic == Const.TOPIC_CATEGORY_DRINK) {
            imageResult = UIImage(named: "ic_drink");
        } else if (typeTopic == Const.TOPIC_CATEGORY_PLAY) {
            imageResult = UIImage(named: "ic_play");
        } else {
            imageResult = UIImage(named: "ic_help");
        }
        return imageResult;
    }

    class func getTopicWhiteBackgroundFormType(typeTopic : Int) -> UIImage{
        var imageResult : UIImage!;
        if (typeTopic == Const.TOPIC_CATEGORY_FOOD) {
            imageResult = UIImage(named: "ic_map_food");
        } else if (typeTopic == Const.TOPIC_CATEGORY_DRINK) {
            imageResult = UIImage(named: "ic_map_drink");
        } else if (typeTopic == Const.TOPIC_CATEGORY_PLAY) {
            imageResult = UIImage(named: "ic_map_play");
        } else {
            imageResult = UIImage(named: "ic_map_help");
        }
        return imageResult;
    }
    
    
    class func setApiKey(token : String){
        UserDefaults.standard.set(token, forKey: Const.USER_DEFAULT_KEY_API_KEY);
    }
    
    class func getApiKey() -> String{
        let obj = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_API_KEY);
        if (obj == nil){
            return "";
        }else{
            return UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_API_KEY) as! String;
        }
    }
    
    class func setWelcome(isWelcome: Bool){
        UserDefaults.standard.set(isWelcome, forKey: Const.USER_DEFAULT_KEY_BADGE_WELCOME);
        if (!isWelcome) {
            UserDefaults.standard.removeObject(forKey: Const.USER_DEFAULT_KEY_BADGE_WELCOME);
        }
    }
    
    class func getWelcome() -> Bool{
        let obj = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_BADGE_WELCOME);
        if (obj == nil){
            return false;
        } else {
            return obj as! Bool;
        }
    }
    
    class func setUserPremium(userId: String, isPremium: Bool) {
        if (!userId.isEmpty) {
            UserDefaults.standard.set(isPremium, forKey: Const.USER_DEFAULT_KEY_PREMIUM_USER + "_" + userId);
        }
    }
    
    class func getUserPremium(userId: String) -> Bool? {
        if (!userId.isEmpty) {
            let objUser = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_PREMIUM_USER + "_" + userId);
            if objUser != nil, let objUserValue = objUser as? Bool {
                return objUserValue;
            }
        }
        
        return nil;
    }
    
    /*
     * set iap not login
     */
    class func setPremium(isPremium: Bool) {
        UserDefaults.standard.set(isPremium, forKey: Const.USER_DEFAULT_KEY_PREMIUM);
    }
    
    /*
     * get iap not login
     */
    class func getPremium() -> Bool {
        let objUser = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_PREMIUM);
        if objUser != nil, let objUserValue = objUser as? Bool {
            return objUserValue;
        }
        return false;
    }
    
    class func setBadgeTabber(number : Int){
        UserDefaults.standard.set(number, forKey: Const.USER_DEFAULT_KEY_BADGE);
        UIApplication.shared.applicationIconBadgeNumber = number;
    }
    
    class func getBadgeTabber() -> Int{
        let obj = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_BADGE);
        if (obj == nil){
            return 0;
        }else{
            return UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_BADGE) as! Int;
        }
    }
    
    /**
     * Create dictionary from object
     */
    class func createDictionary(obj : Any) -> Dictionary<String, Any>{
        var result : Dictionary = Dictionary<String, Any>();
        let mirrored_object = Mirror(reflecting: obj);
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                result.updateValue(attr.value, forKey: property_name)
            }
        }
        return result;
    }
    
    class func createDictionaryLanguage(obj : Any) -> Dictionary<String, String>{
        var result : Dictionary = Dictionary<String, String>();
        let mirrored_object = Mirror(reflecting: obj);
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                if(property_name == "codeLanguage") {
                    result.updateValue(attr.value as! String, forKey: "country");
                } else if (property_name == "level"){
                    result.updateValue(String(attr.value as! Int), forKey: property_name);
                }
            }
        }
        return result;
    }
    
    class func setDeviceToken(token : String){
        UserDefaults.standard.set(token, forKey: Const.USER_DEFAULT_KEY_DEVICE_TOKEN);
    }
    
    class func getDeviceToken() -> String{
        let obj = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_DEVICE_TOKEN);
        if (obj == nil){
            return "";
        }else{
            return UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_DEVICE_TOKEN) as! String;
        }
    }
    
    
    class func getPositionFirstLastAndLengthString(srcStr : String, target : String) -> (String, Int, Int, Int){
        var str = srcStr;
        let rangeStart = str.range(of: target);
        
        let indexStart: Int = str.distance(from: str.startIndex, to: rangeStart!.lowerBound);
        str = str.replacingCharacters(in: rangeStart!, with: "");
        
        let rangeEnd = str.range(of: target);
        let indexEnd: Int = str.distance(from: str.startIndex, to: rangeEnd!.lowerBound);
        str = str.replacingCharacters(in: rangeEnd!, with: "");
        
        return(result: str, first: indexStart, last: indexEnd, length: indexEnd - indexStart);
    }
    
    class func subStringWidthRange(src : String, strRegularExp : UnicodeScalar) -> String?{
//        let us = "http://example.com" , exp: "(?<=://)[^.]+(?=.com)";
        let range = src.range(of: String(strRegularExp), options:.regularExpression)
        if range != nil {
            let found = src.substring(with: range!)
            return found;
        } else {
            return nil;
        }
    }
    
    class func getFullName(user : User) -> String{
        var firstname : String = "";
        var lastName : String = "";
        if (user.fistName != nil){
            firstname = user.fistName!;
        }
        if (user.lastName != nil){
            lastName = user.lastName!;
        }
        
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            return lastName + " " + firstname;
        }else{
            return firstname + " " + lastName;
        }
    }
    
    class func createLabelTermsPolicy(delegate: TTTAttributedLabelDelegate, urlTerms: String, urlPolicy: String) -> TTTAttributedLabel {
        var strTerms = StringUtilities.getLocalizedString("terms_of_use_and_rivacy_policy", comment: "");
        
        let mLabel = TTTAttributedLabel(frame: CGRect.zero);
        mLabel.delegate = delegate;
        
        let fontSize = CGFloat(13);
        let color =  UIColor(hexString: "#4e4a39");
        let colorLink =  UIColor(hexString: "#4e4a39");
        mLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        mLabel.textColor = color;
        mLabel.lineBreakMode = .byWordWrapping
        mLabel.numberOfLines = 0
        
        let searchTerm:(strResult: String, start: Int, end: Int, length: Int) = getPositionFirstLastAndLengthString(srcStr: strTerms!, target: "#");
        strTerms = searchTerm.strResult;
        let rangeTermsText = NSMakeRange(searchTerm.start, searchTerm.length);
        
        let searchPolicy:(strResult: String, start: Int, end: Int, length: Int) = getPositionFirstLastAndLengthString(srcStr: strTerms!, target: "$");
        strTerms = searchPolicy.strResult;
        let rangePolicyText = NSMakeRange(searchPolicy.start, searchPolicy.length);
        
        mLabel.addLink(to: URL(string: urlTerms), with: rangeTermsText);
        mLabel.addLink(to: URL(string: urlPolicy), with: rangePolicyText);
        
        var strTermsStyle = NSMutableAttributedString();
        strTermsStyle = NSMutableAttributedString(string: strTerms! as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
        strTermsStyle.addAttribute(NSForegroundColorAttributeName, value: color ?? UIColor.black,range: NSMakeRange(0, (strTerms?.characters.count)!));
        
        strTermsStyle.addAttribute(NSForegroundColorAttributeName, value: colorLink ?? UIColor.black,range: rangeTermsText);
        strTermsStyle.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue,range: rangeTermsText);
        strTermsStyle.addAttribute(NSForegroundColorAttributeName, value: colorLink ?? UIColor.black,range: rangePolicyText);
        strTermsStyle.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue,range: rangePolicyText);
        mLabel.attributedText = strTermsStyle;
        
        return mLabel;
    }
    
    class func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func getLocation(latitude: Double, longitude: Double, language: String, ViewController viewController : UIViewController, completion: @escaping (_ location: String?, _ error: AnyObject?) -> Void) {
        var url = Const.URL_API_GOOGLE_GET_LOCATION;
        let location = String(latitude) + "," + String(longitude);
        
        url = url.replacingOccurrences(of: "#location#", with: location);
        url = url.replacingOccurrences(of: "#language#", with: language);
        
        APIClient.sharedInstance.getRequest(Url: url, ViewController: viewController, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            let result = responseJson[Const.KEY_RESPONSE_RESULT][0];
            let address = result[Const.KEY_RESPONSE_ADDRESS_API_GOOGLE].stringValue;
            completion(address, nil);
        }) { (error : AnyObject?) in
            completion(nil, error);
        };
    }
    
    class func isJapanese() -> Bool{
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            return true
        }else{
            return false;
        }
    }
    
    class func getLanguageCode() -> String{
        let language : String = NSLocale.preferredLanguages.first!;
        return language.components(separatedBy: "-")[0];
    }
    
   class func getColorFromTypeTopic(typeCategory : Int) -> UIColor{
        if (typeCategory == Const.TOPIC_CATEGORY_PLAY) {
            return UIColor(netHex: Const.COLOR_PLAY);
        } else if (typeCategory == Const.TOPIC_CATEGORY_DRINK){
            return UIColor(netHex: Const.COLOR_DRINK);
        } else if (typeCategory == Const.TOPIC_CATEGORY_FOOD){
            return UIColor(netHex: Const.COLOR_FOOD);
        }else{
            return UIColor(netHex: Const.COLOR_HELP);
        }
    }
    
    class func checkLocationIsEnable(viewVC : UIViewController, locationManager : CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .denied:
                showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewVC, actionOK: { (UIAlertAction) in
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                });
                break;
            case .notDetermined:
                    locationManager.requestAlwaysAuthorization();
                break;
                
            case .authorizedAlways, .authorizedWhenInUse:
                break;
                
            default:
                break;
            }
        } else {
            showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewVC, actionOK: { (UIAlertAction) in
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
            });
        }
    }
    
    class func showBannerAdsInApp(viewController : UIViewController, viewAdMob: UIView, user: User?) {
        self.showBannerAdsInApp(viewController: viewController, viewAdMob: viewAdMob, user: user, heightDefault: nil);
    }
    
    class func showBannerAdsInApp(viewController : UIViewController, viewAdMob: UIView, user: User?, heightDefault: Int?) {
        var hideenAdMob: Bool = false;
        if (user != nil && user?.premiumAccount != nil) {
            hideenAdMob = (user?.premiumAccount)!;
            
            if (Utils.getPremium() != false){
                hideenAdMob = Utils.getPremium();
            }
            
        }else{
            hideenAdMob = Utils.getPremium();
        }
        
        var heightConstraint: NSLayoutConstraint!;
        if (heightDefault != nil) {
            for constraint in viewAdMob.constraints {
                if (constraint.firstAttribute == NSLayoutAttribute.height) {
                    heightConstraint = constraint;
                    break;
                }
            }
        }
        
        if (hideenAdMob) {
            if (heightDefault == nil) {
                for constraint in viewAdMob.constraints {
                    if (constraint.firstAttribute == NSLayoutAttribute.height) {
                        heightConstraint = constraint;
                        break;
                    }
                }
            }
            if (heightConstraint != nil) {
                heightConstraint.constant = CGFloat(0);
            }
        } else {
            if (heightDefault != nil && heightConstraint != nil) {
                heightConstraint.constant = CGFloat(heightDefault!);
            }
            
            let adMob = GADBannerView();
            adMob.translatesAutoresizingMaskIntoConstraints = false;
            viewAdMob.addSubview(adMob);
            
            let leadingConstraint = NSLayoutConstraint(item: adMob, attribute: .leading, relatedBy: .equal, toItem: viewAdMob, attribute: .leading, multiplier: 1.0, constant: 0);
            let trailingConstraint = NSLayoutConstraint(item: adMob, attribute: .trailing, relatedBy: .equal, toItem: viewAdMob, attribute: .trailing, multiplier: 1.0, constant: 0);
            let topConstraint = NSLayoutConstraint(item: adMob, attribute: .top, relatedBy: .equal, toItem: viewAdMob, attribute: .top, multiplier: 1.0, constant: 0);
            let bottomConstraint = NSLayoutConstraint(item: adMob, attribute: .bottom, relatedBy: .equal, toItem: viewAdMob, attribute: .bottom, multiplier: 1.0, constant: 0);
            
            var initialConstraints = Array<NSLayoutConstraint>();
            initialConstraints.append(contentsOf: [leadingConstraint,trailingConstraint,topConstraint,bottomConstraint]);
            NSLayoutConstraint.activate(initialConstraints);
            
            adMob.adUnitID = Const.UNIT_ID_ADMOB_BANNER;
            adMob.rootViewController = viewController;
            let request = GADRequest();
            request.testDevices = [kGADSimulatorID];
            adMob.load(request);
        }
    }
    
    class func showNativeAdsInApp(nativeExpressAdView: GADNativeExpressAdView, viewController : UIViewController){
        nativeExpressAdView.adUnitID = Const.UNIT_ID_ADMOB_NATIVE;
        nativeExpressAdView.rootViewController = viewController
        let request = GADRequest();
        request.testDevices = [kGADSimulatorID];
        nativeExpressAdView.load(request)
    }

    class func getSexCode(gender : String) -> Int{
        if (Const.MALE == gender || Const.MALE_JA == gender){
            return Const.SEXCODE_MALE;
        }else if (Const.FEMALE == gender || Const.FEMALE_JA == gender){
            return Const.SEXCODE_FEMALE;
        }else{
            return Const.SEXCODE_UNKNOWN;
        }
    }

    class func setIntroduction(isShow: Bool) {
        UserDefaults.standard.set(isShow, forKey: Const.USER_DEFAULT_KEY_INTRODUCTION_FIRST);
    }

    class func getIntroduction() -> Bool {
        let objIntroductionFirst = UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_INTRODUCTION_FIRST);
        if objIntroductionFirst != nil, let objValue = objIntroductionFirst as? Bool {
            return objValue;
        }

        return true;
    }
}
