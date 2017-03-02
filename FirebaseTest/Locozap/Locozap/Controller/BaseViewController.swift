/**
 * BaseViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import Photos;

class BaseViewController: UIViewController {
    
    var mUser : User?;
    
    init() {
        let namexib = String(describing: type(of: self))
        super.init(nibName: namexib, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if (mUser == nil && Utils.getInfoAccount() != nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            mUser = appDelegate.mUser;
        }
        
        initNavigationBar();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if (self.mUser != nil && self.mUser?.id != nil) {
            let isPremiumLocal = Utils.getUserPremium(userId: (self.mUser?.id)!);
            let isPremiumUser = self.mUser?.premiumAccount != nil ? self.mUser?.premiumAccount! : false;
            
            let isPremiumNotLogin = Utils.getPremium();
            
            if ( (isPremiumLocal != nil && isPremiumLocal != isPremiumUser) || (isPremiumNotLogin != false && isPremiumNotLogin != isPremiumUser)) {
                self.callApiActivePremium(activeSuccess: self.setUser, activeError: {
                    
                });
            }
        }
    }
    
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(netHex: Const.COLOR_PRIMARY);
        self.navigationController?.navigationBar.isTranslucent = false;
        let backButton = UIBarButtonItem(image: getBackImage().withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.didPressBack));
  
        self.navigationItem.leftBarButtonItem = backButton;
        
        let navFont : UIFont?;
        let language = NSLocale.preferredLanguages.first;
        if language?.hasPrefix("ja") == true {
            navFont = UIFont(name: Const.HIRAKAKUPRO_W6, size: 13);
        }else{
            navFont = UIFont.systemFont(ofSize: 13);
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;

        let navBarAttributesDictionary: [String: AnyObject]? = [
            (NSForegroundColorAttributeName as NSObject) as! String: UIColor(netHex: Const.COLOR_WHITE),
            (NSFontAttributeName as NSObject) as! String: navFont!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPressBack() {
		if (self.navigationController != nil){
			self.navigationController!.popViewController(animated: true);
		}else{
			self.dismiss(animated: true, completion: nil);
		}
    }
    
    func getBackImage() -> UIImage {
        return UIImage(named: "img_back")!;
    }
    
    public func setAdMob(viewAdMob: UIView) {
        var user: User! = nil;
        
        if (self.mUser != nil && self.mUser?.id != nil) {
            user = User();
            user.premiumAccount = self.mUser?.premiumAccount;
            let isPremiumLocal = Utils.getUserPremium(userId: (self.mUser?.id)!);
            let isPremiumUser = user?.premiumAccount != nil ? user?.premiumAccount! : false;
            if (isPremiumLocal != nil && isPremiumLocal != isPremiumUser) {
                user?.premiumAccount = isPremiumLocal;
            }
        }
        Utils.showBannerAdsInApp(viewController: self, viewAdMob: viewAdMob, user: user);
    }
    
    private func callApiActivePremium(activeSuccess : @escaping (_ response: Any) -> Void, activeError : @escaping () -> Void) {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        
        APIClient.sharedInstance.postRequest(Url: URL_ACTIVE_PREMIUM, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
            let responseJson = JSON(success)["data"];
            Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: responseJson.rawValue) as AnyObject?);
            
            activeSuccess(responseJson.rawValue);
        }) { (error : AnyObject?) in
            activeError();
        }
    }
    
    private func setUser(response: Any) {
        Utils.setUserPremium(userId: (self.mUser?.id)!, isPremium: true);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.mUser?.premiumAccount = true;
        
        Utils.setInfoAccount(infoAccount: NSKeyedArchiver.archivedData(withRootObject: response) as AnyObject?);
    }
    
    public func isUserPremium() -> Bool {
        var user: User! = nil;
        
        if (self.mUser != nil && self.mUser?.id != nil) {
            user = User();
            user.premiumAccount = self.mUser?.premiumAccount;
            let isPremiumLocal = Utils.getUserPremium(userId: (self.mUser?.id)!);
            let isPremiumUser = user?.premiumAccount != nil ? user?.premiumAccount! : false;
            
            if (isPremiumLocal != nil && isPremiumLocal != isPremiumUser) {
                user?.premiumAccount = isPremiumLocal;
            }
            
            let isPremiumNotLogin = Utils.getPremium();
            if (isPremiumNotLogin != false){
//                user?.premiumAccount = isPremiumNotLogin;
                return true;
            }
            
            if (user?.premiumAccount != nil) {
                return (user?.premiumAccount)!;
            }
        }else{
            let isPremium = Utils.getPremium();
            return isPremium;
        }
        
        return false;
    }
    
    func requestPhotoPermistion() {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.notDetermined) {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
            })
        }
    }
    
    func requestCameraPermistion(){
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if (status == .notDetermined) {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                DispatchQueue.main.async() {
                    
                } }
        }
    }
}
