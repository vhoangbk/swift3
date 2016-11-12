//
//  LoginAccountViewController.swift
//  Locozap
//
//  Created by paraline on 10/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class LoginAccountViewController: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mEdtUserName: UITextField!;
    @IBOutlet weak var mEdtPassword: UITextField!;
    @IBOutlet weak var mBtnLogin: LocalizedButton!;
    @IBOutlet weak var mBtnRegister: LocalizedButton!;
    
    let locationManager = CLLocationManager();
    var locationValue:CLLocationCoordinate2D = CLLocationCoordinate2D();

    override func viewDidLoad() {
        super.viewDidLoad()
        initView();
        initLocationManager();
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginAccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView(){
        let strHintUserName = NSLocalizedString("enter_user_name", comment: "");
        let strHintPassword = NSLocalizedString("enter_password", comment: "");
        let strBtnLogin = NSLocalizedString("btn_login", comment: "");
        let strBtnRegister = NSLocalizedString("btn_register_account", comment: "");
        mBtnLogin.setTitle(strBtnLogin, for: UIControlState.normal);
        mBtnRegister.setTitle(strBtnRegister, for: UIControlState.normal);
        mEdtPassword.placeholder = strHintUserName
        mEdtUserName.placeholder = strHintPassword;
    }
    
    @IBAction func pressActionLogin(_ sender: AnyObject) {
        validate();
    }
    
    
    // MARK: -- Call api and validate befor call api
    
    /**
     *  Validate data befor call api login
     *
     */
    func validate (){
        if (mEdtUserName.text != "") {
            if (mEdtPassword.text != "") {
                callApiLogin();
            } else {
                Utils.showAlertWithTitle("", message: NSLocalizedString("password_empty", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
                return;
            }
        } else {
            Utils.showAlertWithTitle("", message: NSLocalizedString("user_name_empty", comment: ""), titleButtonClose: "", titleButtonOk: NSLocalizedString("btn_ok", comment: ""), viewController: self, actionOK: nil);
            return;
        }
    }
    
    func callApiLogin(){
		
        var params : Dictionary = Dictionary<String, String>();
        params.updateValue(mEdtUserName.text!, forKey: Const.KEY_PARAMS_USERNAME);
        params.updateValue(mEdtPassword.text!, forKey: Const.KEY_PARAMS_PASSWORD);
        params.updateValue(String(locationValue.longitude), forKey: Const.KEY_PARAMS_LONGITUDE);
        params.updateValue(String(locationValue.latitude), forKey: Const.KEY_PARAMS_LATITUDE);
		
		let loginRequest : LoginRequest = (ObjectMapper.sharedInstance().object(fromSource: params, toInstanceOf: LoginRequest.self) as? LoginRequest)!
		
//        APIClient.sharedInstance.postRequestObject(Url: URL_LOGIN, Parameters: loginRequest, ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
//                let responseJson = JSON(success)["data"];
//                Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
//                let mainVc = MainViewController();
//                self.navigationController?.pushViewController(mainVc, animated: true);
//        }) { (error : AnyObject?) in
//            
//		}, Class: LoginResponse)
		
		APIClient.sharedInstance.postRequestObject(Url: URL_LOGIN, Parameters: loginRequest, ViewController: self, ShowProgress: true, ShowAlert: true, Success: { (success : AnyObject) in
			
			print(success);
			
			
				let loginResponse : LoginResponse = (ObjectMapper.sharedInstance().object(fromSource: success, toInstanceOf: LoginResponse.self) as? LoginResponse)!
				print(loginResponse.avatar)

			}, Failure: { (error : AnyObject?) in
				
			})
		
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
    
    func dismissKeyboard() {
        mEdtUserName.resignFirstResponder();
        mEdtPassword.resignFirstResponder();
    }
}
