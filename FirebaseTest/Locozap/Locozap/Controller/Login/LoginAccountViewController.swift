/**
 * LoginAccountViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import CoreLocation

class LoginAccountViewController: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mEdtUserName: UITextField!;
    @IBOutlet weak var mEdtPassword: UITextField!;
    @IBOutlet weak var lbForgotPassword: UILabel!

    
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();
    
    private var shadowImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        initLocationManager();

        //dismis keyboad
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginAccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //tap forgot password
        let tapForgot = UITapGestureRecognizer(target: self, action: #selector(LoginAccountViewController.tabForgotPassword))
        lbForgotPassword.addGestureRecognizer(tapForgot)
    }
    
    override func initNavigationBar() {
        super.initNavigationBar();
        
        let nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 30));
        nextBtn.setTitle(StringUtilities.getLocalizedString("login", comment: ""), for: UIControlState.normal);
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16);
        nextBtn.setBackgroundImage(UIImage.init(named: "button_bg_corner")!, for: UIControlState.normal);
        nextBtn.addTarget(self, action: #selector(LoginAccountViewController.pressLogin), for: UIControlEvents.touchUpInside);
        let next = UIBarButtonItem(customView: nextBtn);
        self.navigationItem.rightBarButtonItem = next;
        
    }
    
    override func getBackImage() -> UIImage {
        return UIImage(named: "img_cancel")!;
    }
    
    override func didPressBack() {
        dismiss(animated: true, completion: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        
        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }
        shadowImageView?.isHidden = true
    }

    func pressLogin() {
        mEdtUserName.resignFirstResponder();
        mEdtPassword.resignFirstResponder();
        if (validate() == true){
            callApiLogin();
        }
    }

    func initView(){
        
        let strHintUserName = NSAttributedString(string: StringUtilities.getLocalizedString("enter_user_name", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        mEdtUserName.attributedPlaceholder = strHintUserName

        let strHintPassword = NSAttributedString(string: StringUtilities.getLocalizedString("login_password", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.init(netHex: Const.COLOR_PLACEHOLDER)])
        mEdtPassword.attributedPlaceholder = strHintPassword
        
        lbForgotPassword.text = StringUtilities.getLocalizedString("forget_password", comment: "");
    }
    
    @IBAction func pressActionLogin(_ sender: AnyObject) {
        
    }
    
    
    // MARK: -- Call api and validate befor call api
    
    /**
     *  Validate data befor call api login
     *
     */
    func validate () -> Bool{
        
        let userName = mEdtUserName.text?.trim();
        let password = mEdtPassword.text;
        
        if (userName?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("user_name_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (Utils.isValidEmail(testStr: userName!) == false){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("email_incorect_format", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if (password?.isEmpty == true){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        if ((password?.characters.count)! < 6){
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("password_less_6_character", comment: ""), titleButtonClose: "", titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return false;
        }
        
        return true;
    }
    
    func callApiLogin(){
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue(mEdtUserName.text!, forKey: Const.KEY_PARAMS_EMAIL);
        params.updateValue(mEdtPassword.text!, forKey: Const.KEY_PARAMS_PASSWORD);
        params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
        params.updateValue(String(Const.LOGIN_DEFAULT), forKey: Const.KEY_PARAMS_LOGIN_TYPE);
        params.updateValue(Utils.getDeviceToken(), forKey: Const.KEY_PARAMS_DEVICE_TOKEN);
        
        APIClient.sharedInstance.postRequest(Url: URL_LOGIN, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
                let responseJson = JSON(success)["data"];
                Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let mainVc = MainViewController();
            let naviVC = UINavigationController(rootViewController: mainVc);
            appDelegate.window?.rootViewController = naviVC;
            appDelegate.window?.makeKeyAndVisible();
            
        }) { (error : AnyObject?) in
            
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
        locationManager.stopUpdatingLocation()
    }
    
    func dismissKeyboard() {
        mEdtUserName.resignFirstResponder();
        mEdtPassword.resignFirstResponder();
    }
    
    func tabForgotPassword() {
        let forgotVC = ForgotPasswordViewController();
        self.navigationController?.pushViewController(forgotVC, animated: true);
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
}
