//
//  MainViewController.swift
//  Locozap
//
//  Created by Hoang Nguyen on 10/11/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController : UITabBarController, UITabBarControllerDelegate, PostDialogDelegate {
	
    var tab3 : UITabBarItem?;
    
	override func viewDidLoad() {
        
        if Utils.getInfoAccount() != nil {
            self.parserUser();
        }
		
        SocketIOManager.sharedInstance.connect();
        
		//home
		let homeVC = HomeViewController();
		
		//map
		let mapVC = MapViewController();
		
		//posts
		let postVC = PostsViewController();
//		postVC.modalPresentationStyle = .overCurrentContext
		
		//notification
		let notificationVC = NotificationViewController();
		
		//profile
		let profileVC = ProfileViewController();
		
		self.setViewControllers([homeVC, mapVC, postVC, notificationVC, profileVC], animated: true);
		
		//tabbar
		self.tabBar.backgroundColor = UIColor.white;

		let tabbars : UITabBar = self.tabBar;
		let tab1 : UITabBarItem = tabbars.items![0];
		let tab2 : UITabBarItem = tabbars.items![1];
		tab3 = tabbars.items![2];
		let tab4 : UITabBarItem = tabbars.items![3];
		let tab5 : UITabBarItem = tabbars.items![4];
		
		tab1.image = UIImage(named: "tabbar_home_nomal");
		tab1.selectedImage = UIImage(named: "tabbar_home_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		tab1.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
		
		tab2.image = UIImage(named: "tabbar_search_nomal");
		tab2.selectedImage = UIImage(named: "tabbar_search_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		tab2.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
		
		tab3?.image = UIImage(named: "tabbar_posts")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		tab3?.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)

		tab4.image = UIImage(named: "tabbar_notification_nomal");
		tab4.selectedImage = UIImage(named: "tabbar_notification_active")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		tab4.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
		
		tab5.image = UIImage(named: "tabbar_profile_nomal");
		tab5.selectedImage = UIImage(named: "tabbar_profile_activie")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		tab5.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
		
        self.delegate = self;
        
        SocketIOManager.sharedInstance.onNewMessageUser { (data : Any) in
            self.parserNewMessage(data: JSON(data));
            
        }
        
	}
    
    func parserUser() {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: (Utils.getInfoAccount() as! NSData) as Data);
        let response = JSON(dict)
        
        let paserHelper : ParserHelper = ParserHelper();
        
        let user = paserHelper.parserUser(data: response);
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        appDelegate.mUser = user;
        
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: true);
	}
   
    //MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: PostsViewController.classForCoder()) {
            let postDialog = PostDialog.sharedInstance();
            postDialog.delegate = self;
            postDialog.show();
            self.tab3?.image = nil;
            
            return false;
        }
        return true;
    }
    
    // MARK : Delegate post dialog
    
    func didPressMenuFood() {
        gotoPostActivity();
    }

    func didPressMenuHelp() {
        gotoPostActivity();
    }
    
    func didPressMenuDrink() {
        gotoPostActivity();
    }
    
    func didPressMenuPlay() {
        gotoPostActivity();
    }
    
    func didDismiss() {
        tab3?.image = UIImage(named: "tabbar_posts")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    func gotoPostActivity(){
        let postsActivityVC = PostsActivityViewController();
        self.navigationController?.pushViewController(postsActivityVC, animated: true);
    }
    
    func parserNewMessage(data : JSON) {
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
        let notification = UILocalNotification();
        notification.fireDate = Date()
        if Message.MESSAGE_SERVER_TYPE_TEXT == message.type {
            notification.alertBody = user.fistName! + " " + user.lastName! + ": " + message.message!;
        }else if Message.MESSAGE_SERVER_TYPE_IMAGE == message.type {
            notification.alertBody = user.fistName! + " " + user.lastName! + ": share photo";
        }else if Message.MESSAGE_SERVER_TYPE_LOCATION == message.type {
            notification.alertBody = user.fistName! + " " + user.lastName! + ": share loation";
        }
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.timeZone = NSTimeZone.default;
        UIApplication.shared.scheduleLocalNotification(notification);
    }

}
