/**
 * MainViewController
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON

class MainViewController : UITabBarController, UITabBarControllerDelegate, PostDialogDelegate {
    var tab3 : UITabBarItem?;
    
    public static var tabSelectedIndex = 0;
    private var mUser: User?;
    
    let locationManager = CLLocationManager();
    
	override func viewDidLoad() {
        super.viewDidLoad();
        
//        if Utils.getInfoAccount() != nil {
//            self.parserUser();
//        }
//		//home
//		let homeVC = HomeViewController();
//		
//		//map
//		let mapVC = MapViewController();
//		
//		//posts
//		let postVC = PostsViewController();
//		
//		//notification
//		let notificationVC = NotificationViewController();
//		
//		//profile
//		let profileVC = MyProfileViewController();
//		
//		self.setViewControllers([homeVC, mapVC, postVC, notificationVC, profileVC], animated: true);
//		
//		//tabbar
//		self.tabBar.backgroundColor = UIColor.white;
//
//		let tabbars : UITabBar = self.tabBar;
//		let tab1 : UITabBarItem = tabbars.items![0];
//		let tab2 : UITabBarItem = tabbars.items![1];
//		tab3 = tabbars.items![2];
//		let tab4 : UITabBarItem = tabbars.items![3];
//		let tab5 : UITabBarItem = tabbars.items![4];
//		
//		tab1.image = UIImage(named: "tabbar_home_nomal")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal);
//		tab1.selectedImage = UIImage(named: "tabbar_home_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		tab1.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
//		
//		tab2.image = UIImage(named: "tabbar_search_nomal")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal);
//		tab2.selectedImage = UIImage(named: "tabbar_search_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		tab2.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
//		
//		tab3?.image = UIImage(named: "tabbar_posts")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		tab3?.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
//
//		tab4.image = UIImage(named: "tabbar_notification_nomal")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal);
//		tab4.selectedImage = UIImage(named: "tabbar_notification_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		tab4.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
//		
//		tab5.image = UIImage(named: "tabbar_profile_nomal")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal);
//		tab5.selectedImage = UIImage(named: "tabbar_profile_activie")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		tab5.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
//		
//        self.delegate = self;
//        
//        self.selectedIndex = MainViewController.tabSelectedIndex;
//        MainViewController.tabSelectedIndex = 0;
//        
//        let numberBadge = Utils.getBadgeTabber();
//        self.setBadge(value: numberBadge);
//		
//        if (!SocketIOManager.sharedInstance.connected()){
//            SocketIOManager.sharedInstance.connect();
//        }else{
//            SocketIOManager.sharedInstance.emitActionConnect();
//        }
//        
//		SocketIOManager.sharedInstance.listenerGlobal();
//		
//        locationManager.requestWhenInUseAuthorization();
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.catchSetBadgeTabNotification), name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: nil);
//        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.parserNewMessage), name: Const.KEY_NOTIFICATION_NEW_MESSAGE_USER, object: nil);
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: nil);
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_NEW_MESSAGE_USER, object: nil);
    }
    
    func parserUser() {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: (Utils.getInfoAccount() as! NSData) as Data);
        let response = JSON(dict!)
        
        let paserHelper : ParserHelper = ParserHelper();
        
        let user = paserHelper.parserUser(data: response);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        appDelegate.mUser = user;
        self.mUser = user;
        
        if (Utils.getApiKey() == ""){
            Utils.setApiKey(token: user.apiKey!);
        }
        
        
    }
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.screenPosition = AppDelegate.MAIN_POSITION;
        
        let hasWelcome = Utils.getWelcome();
        if (hasWelcome) {
            Utils.setWelcome(isWelcome: false);
            let objSetTabbar = SystemSetInfoBadgeTabbar(isWelcome: true);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
        }
        
        callApiUnReadTotal();
	}
   
    //MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: PostsViewController.classForCoder()) {
            let postDialog = PostDialog.sharedInstance();
            postDialog.delegate = self;
            postDialog.show(tabBarController: tabBarController);
            self.tab3?.image = nil;
            
            return false;
        }
        
        if(viewController.isKind(of: MapViewController.classForCoder())){
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined:
                    locationManager.requestAlwaysAuthorization();
                    break;
                case .denied :
                    Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (UIAlertAction) in
                    
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                    });
                    return false;
                default :
                break;
            }
            } else {
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("warning_gps", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_ok", comment: ""), viewController: viewController, actionOK: { (UIAlertAction) in
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL);
                });
                return false;
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if (appDelegate.mUser == nil){
            if viewController.isKind(of: NotificationViewController.classForCoder()) {
                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("you_can_set_it_by_registering_an_account", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                    
                    let loginVC = LoginViewController();
                    self.navigationController?.pushViewController(loginVC, animated: true);
                    
                })
                return false;
            }
            
//            if viewController.isKind(of: MyProfileViewController.classForCoder()) {
//                Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("once_you_register_your_account_you_will_be_able_to_follow_the_user", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
//                    
//                    let loginVC = LoginViewController();
//                    self.navigationController?.pushViewController(loginVC, animated: true);
//                    
//                })
//                return false;
//            }
            
        }else{
            if viewController.isKind(of: NotificationViewController.classForCoder()) {
                UIApplication.shared.applicationIconBadgeNumber = 0;
            }
        }
        
        return true;
    }
    
    // MARK : Delegate post dialog
    func didPressMenuFood() {
        if ( self.checkLoginPost() == true ){
            gotoPostActivity(typePost: Const.TOPIC_CATEGORY_FOOD);
        }
    }

    func didPressMenuHelp() {
        if ( self.checkLoginPost() == true ){
            gotoPostActivity(typePost: Const.TOPIC_CATEGORY_HELP);
        }
    }
    
    func didPressMenuDrink() {
        if ( self.checkLoginPost() == true ){
            gotoPostActivity(typePost: Const.TOPIC_CATEGORY_DRINK);
        }
    }
    
    func didPressMenuPlay() {
        if ( self.checkLoginPost() == true ){
            gotoPostActivity(typePost: Const.TOPIC_CATEGORY_PLAY);
        }
    }
    
    /*
     * check login to post topic
     */
    func checkLoginPost() -> Bool{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if ( appDelegate.mUser == nil ){
            
            Utils.showAlertWithTitle("", message: StringUtilities.getLocalizedString("once_you_register_your_account_you_can_post_it", comment: ""), titleButtonClose: StringUtilities.getLocalizedString("cancel", comment: ""), titleButtonOk: StringUtilities.getLocalizedString("btn_register", comment: ""), viewController: self, actionOK: { (alert : UIAlertAction) in
                let loginVC = LoginViewController();
                self.navigationController?.pushViewController(loginVC, animated: true);
            })
            return false;
        }
        
        return true;
    }
    
    func didDismiss() {
        tab3?.image = UIImage(named: "tabbar_posts")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    func gotoPostActivity(typePost : Int){
        let postsActivityVC = PostsActivityViewController();
        var color : UIColor!;
        if (typePost == Const.TOPIC_CATEGORY_PLAY) {
            color = UIColor(netHex: Const.COLOR_PLAY);
            postsActivityVC.typeTopic = Const.TOPIC_CATEGORY_PLAY;
            
        } else if (typePost == Const.TOPIC_CATEGORY_DRINK){
            color = UIColor(netHex: Const.COLOR_DRINK);
            postsActivityVC.typeTopic = Const.TOPIC_CATEGORY_DRINK;
            
        } else if (typePost == Const.TOPIC_CATEGORY_FOOD){
            color = UIColor(netHex: Const.COLOR_FOOD);
            postsActivityVC.typeTopic = Const.TOPIC_CATEGORY_FOOD;
            
        }else{
            color = UIColor(netHex: Const.COLOR_HELP);
            postsActivityVC.typeTopic = Const.TOPIC_CATEGORY_HELP;
            
        }
        postsActivityVC.colorTabBar = color;
        present(UINavigationController(rootViewController: postsActivityVC), animated: true, completion: nil);

    }

    func parserNewMessage(notification: NSNotification) {
        let data = JSON(notification.object!);
        let parserHelper : ParserHelper = ParserHelper();
        let messageJson = data["message"];
        let message = parserHelper.parserMessage(data: messageJson);
        
        let userJson = data["user"];
        let user = parserHelper.parserUser(data: userJson);
        
        //
        print(data);
        self.showNotification(user: user, message: message);
    }
    
    func showNotification(user : User, message : Message) {
        
        let objMessage = ObjectMessage.createObject(userAction: user, lastMessage: message, typeMessage: TypeMessage.OneToOne);
        
        NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_MESSAGE, object: objMessage, userInfo: nil);
        
        if (user.unReadTotal != nil) {
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: user.unReadTotal!);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
        }
    }
    
    private func callApiUnReadTotal() {
        var params : Dictionary = Dictionary<String, String>();
        if (mUser == nil) {
            return;
        }
        params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
        
        APIClient.sharedInstance.postRequest(Url: URL_GET_UNREAD_TOTAL, Parameters: params as [String : AnyObject], ViewController: self, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
            let responseJson = JSON(success);
            let unReadTotalResponse = responseJson[Const.KEY_RESPONSE_DATA];
            let paserHelper : ParserHelper = ParserHelper();
            let unReadTotal : UnReadTotal = paserHelper.pareserModel(data: unReadTotalResponse);
            let objSetTabbar = SetInfoBadgeTabbar(type: TypeSetInfoBadgeTabbar.Fix, value: unReadTotal.total);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
        }) { (error : AnyObject?) in
        }
    }

    @objc private func catchSetBadgeTabNotification(notification: NSNotification) {
        let data = notification.object as! ISetInfoBadgeTabbar;
        let currentValue: Int = (self.tabBar.items?[3].tag)!;
        var newValue: Int;
        if let view: NotificationViewController = self.selectedViewController as? NotificationViewController {
            data.setViewController(view: view);
        }
        
        switch data.type {
        case TypeSetInfoBadgeTabbar.Increment:
            newValue = currentValue + data.getValue();
        case TypeSetInfoBadgeTabbar.Decrement:
            newValue = currentValue - data.getValue();
        case TypeSetInfoBadgeTabbar.Fix:
            newValue = data.getValue();
        case TypeSetInfoBadgeTabbar.Welcome:
            newValue = data.getValue();
            Utils.setWelcome(isWelcome: false);
        default:
            newValue = 0;
        }
        
        self.setBadge(value: newValue);
        
        Utils.setBadgeTabber(number: newValue);
    }
    
    private func setBadge(value: Int) {
        if (value <= 0) {
            self.tabBar.items?[3].badgeValue = nil;
            self.tabBar.items?[3].tag = 0;
            Utils.setBadgeTabber(number: 0);
        } else {
            self.tabBar.items?[3].badgeValue = String(value);
            self.tabBar.items?[3].tag = value;
            Utils.setBadgeTabber(number: value);
        }
    }
}
