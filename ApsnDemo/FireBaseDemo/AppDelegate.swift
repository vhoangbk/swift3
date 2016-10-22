//
//  AppDelegate.swift
//  FireBaseDemo
//
//  Created by Hoang Nguyen on 10/22/16.
//  Copyright © 2016 Hoang Nguyen. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		self.registerApns();
		
		return true
	}
	
	func registerApns() {
		if #available(iOS 10.0, *) {
			let center = UNUserNotificationCenter.current()
			center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
				
				// Enable or disable features based on authorization.
				if granted == true
				{
					print("Allow")
					UIApplication.shared.registerForRemoteNotifications()
				}
				else
				{
					print("Don't Allow")
				}
			}
		} else {
			let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			UIApplication.shared.registerUserNotificationSettings(settings)
			UIApplication.shared.registerForRemoteNotifications()
		}
		
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		var token: String = ""
		for i in 0..<deviceToken.count {
			token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
		}
		
		print(token)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		print(userInfo)
	}
	
	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
		print(notification)
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error);
	}
	
	

}

