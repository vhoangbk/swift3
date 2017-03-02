/**
 * Locozap AppDelegate
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import SwiftyJSON
import CoreData
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mUser : User?;
    
    let gcmMessageIDKey = "gcm.message_id"
    
    static let MAIN_POSITION = 1;
    static let USER_PROFILE_POSITION = 2;
    static let CHAT_GROUP_POSITION = 3;
    static let CHAT_ONE_POSITION = 4;
    static let SETTING_POSITION = 5;
    static let PUSH_DETAIL_POSITION = 6;
    var screenPosition : Int = 0;
    
    private var reachability:Reachability!;
    var isInternetConnected : Bool = true;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.window = UIWindow(frame: UIScreen.main.bounds);

        let naviVC : UINavigationController;
        
        let introductionVC = IntroductionViewController();
        naviVC = UINavigationController(rootViewController: introductionVC);
        
        self.window?.rootViewController = naviVC;
        self.window?.makeKeyAndVisible();
        
         self.initFirebase(application: application);

//        if Utils.getIntroduction() {
//            let introductionVC = IntroductionViewController();
//            naviVC = UINavigationController(rootViewController: introductionVC);
//        } else {
//            let mainVC = MainViewController();
//            naviVC = UINavigationController(rootViewController: mainVC);
//        }
//        self.window?.rootViewController = naviVC;
//        self.window?.makeKeyAndVisible();
//        
//        self.initFirebase(application: application);
//        
//        //jp.co.locobee.app: f6a8b7fccd1303f0a49ffb2ca24286f9aec39e2a
//        //jp.co.locobee: 6177af7ca8ed763e3d833baf667bdd254d6c1edd
//        DeployGateSDK.sharedInstance().launchApplication(withAuthor: "hoangnv", key: "f6a8b7fccd1303f0a49ffb2ca24286f9aec39e2a");
//        
//        FBSDKApplicationDelegate.sharedInstance().application(application , didFinishLaunchingWithOptions: launchOptions);
//		
//        GADMobileAds.configure(withApplicationID: Const.APP_ID_ADMOB_BANNER);
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil);
//        self.reachability = Reachability.forInternetConnection();
//        self.reachability.startNotifier();
//        
//        if (NSClassFromString("ASIdentifierManager") != nil) {
//            let ifa: UUID? = ASIdentifierManager.shared().advertisingIdentifier
//            let isAppleAdvertisingTrackingEnalbed: Bool = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
//            IgaworksCore.setAppleAdvertisingIdentifier(ifa?.uuidString, isAppleAdvertisingTrackingEnabled: isAppleAdvertisingTrackingEnalbed)
//            print("[ifa UUIDString] \(ifa?.uuidString)")
//        }
//        IgaworksCore.igaworksCore(withAppKey: "558666836", andHashKey: "0c697edf580046d5")
//        IgaworksCore.setLogLevel(IgaworksCoreLogTrace)
//        AdBrix.firstTimeExperience("Locobee_Application_Started")
        
        return true;
    }
    
    func initFirebase(application : UIApplication) {
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String;
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation];
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation);
    }
    
    @available(iOS, introduced: 8.0, deprecated: 9.0)
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation);
    }
    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            NSLog("Message ID 1 ios<10: \(messageID)")
        }
        
        // Print full message.
        NSLog("\(userInfo)")
        
        // Print full message.
        // Print full message.
        if let aps = userInfo["aps"] as? NSDictionary {
            if let badge = aps["badge"] as? Int {
                switch application.applicationState {
                case .active:
                    //app is currently active, can update badges count here
                    print("//app is currently active, can update badges count here");
                    processNotification(userInfo: userInfo, badge: badge, isTapNotification: false);
                    break
                case .inactive:
                    //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                    print("//app is transitioning from background to foreground (user taps notification), do what you need when user taps here");
                    processNotification(userInfo: userInfo, badge: badge, isTapNotification: true);
                    break
                case .background:
                    //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                    print("//app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here");
                    break
                default:
                    print("default");
                    break
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            NSLog("Message ID 2 ios<10: \(messageID)")
        }
        
        // Print full message.
        NSLog("\("userInfo")")
        
        
        // Print full message.
        if let aps = userInfo["aps"] as? NSDictionary {
            if let badge = aps["badge"] as? Int {
                switch application.applicationState {
                case .active:
                    //app is currently active, can update badges count here
                    print("//app is currently active, can update badges count here");
                    processNotification(userInfo: userInfo, badge: badge, isTapNotification: false);
                    break
                case .inactive:
                    //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                    print("//app is transitioning from background to foreground (user taps notification), do what you need when user taps here");
                    processNotification(userInfo: userInfo, badge: badge, isTapNotification: true);
                    break
                case .background:
                    //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                    print("//app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here");
                    break
                default:
                    print("default");
                    break
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            NSLog("InstanceID token: \(refreshedToken)")
            
            Utils.setDeviceToken(token: refreshedToken);
            
            sendRegistrationToServer(tokenDevice: refreshedToken);
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                NSLog("Unable to connect with FCM. \(error)")
            } else {
                NSLog("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("APNs token retrieved: \(deviceToken)")
        
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        NSLog(token)
        
        // With swizzling disabled you must set the APNs token here.
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
		SocketIOManager.sharedInstance.disconnect();
        SocketIOManager.sharedInstance.offListenerGlobal();
        FIRMessaging.messaging().disconnect()
        NSLog("Disconnected from FCM.")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("applicationDidBecomeActive")
		SocketIOManager.sharedInstance.connect();
//        SocketIOManager.sharedInstance.emitActionConnect();
        SocketIOManager.sharedInstance.listenerGlobal();
        connectToFcm()
    }
    
    func reachabilityChanged(notification : Notification) {
        let curReach : Reachability = notification.object as! Reachability;
        
        if (curReach.currentReachabilityStatus().rawValue == 0) {
            self.isInternetConnected = false;
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_NETWORK, object: false, userInfo: nil);
        }else{
            self.isInternetConnected = true;
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_NETWORK, object: true, userInfo: nil);
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.removeObserver(self, name: Const.KEY_NOTIFICATION_RELOADS_TOP_WHEN_CREATE_TOPIC, object: nil);
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Locozap")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func registerApns() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                
                // Enable or disable features based on authorization.
                if granted == true
                {
                    NSLog("Allow")
                    UIApplication.shared.registerForRemoteNotifications()
                }
                else
                {
                    NSLog("Don't Allow")
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
    }
    
    func sendRegistrationToServer(tokenDevice : String) {
        var params : Dictionary = Dictionary<String, String>();
        if(mUser?.apiKey != nil) {
            params.updateValue((mUser?.apiKey)!, forKey: Const.KEY_PARAMS_API_KEY);
            if (tokenDevice !=  ""){
                params.updateValue(tokenDevice, forKey: Const.KEY_PARAMS_DEVICE_TOKEN);
            }
    
            APIClient.sharedInstance.postRequest(Url: URL_UPDATE_USER, Parameters: params as [String : AnyObject], ViewController: (window?.rootViewController)!, ShowProgress: false, ShowAlert: false, Success: { (success : AnyObject) in
            
            
            }) { (error : AnyObject?) in
           
            }
        }
    }
    
    public func processNotification(userInfo: [AnyHashable : Any], badge: Int, isTapNotification: Bool) {
        print(userInfo);
        
        let type = userInfo["type"] as? String;
        if (type != nil) {
            NSLog("Type: " + type!);
            
            if (isTapNotification) {
                self.pressNotification(userInfo: userInfo, type: type!, badge: badge);
            } else {
                if (type == "10") {
                    let topic = userInfo["topic"] as? String;
                    let topicJson = JSON(data: (topic?.data(using: String.Encoding.utf8))!);
                    let paserHelper : ParserHelper = ParserHelper();
                    let message : ObjectMessage = paserHelper.pareserModel(data: topicJson);
                    
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_MESSAGE, object: message, userInfo: nil);
                    
                    let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: badge);
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
                } else if (type == "11") {
                    let push = userInfo["message"] as? String;
                    let pushJson = JSON(data: (push?.data(using: String.Encoding.utf8))!);
                    let paserHelper : ParserHelper = ParserHelper();
                    let notification : ObjectNotification = paserHelper.pareserModel(data: pushJson);
                    
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_PUSH, object: notification, userInfo: nil);
                    
                    let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: badge);
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
                } else if (type == "1") {
                    Utils.setWelcome(isWelcome: true);
                    let objSetTabbar = SystemSetInfoBadgeTabbar(isWelcome: true);
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
                }
            }
        } else {
            NSLog("Type nil");
        }
    }
    
    private func pressNotification(userInfo: [AnyHashable : Any], type: String, badge: Int) {
        
        let state: UIApplicationState = UIApplication.shared.applicationState;
        
        if(type == "11") {
            //like
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: badge);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            
            let push = userInfo["message"] as? String;
            let pushJson = JSON(data: (push?.data(using: String.Encoding.utf8))!);
            let paserHelper : ParserHelper = ParserHelper();
            let notification : ObjectNotification = paserHelper.pareserModel(data: pushJson);
            
            let topic = userInfo["topic"] as? String;
            let topicJson = JSON(data: (topic?.data(using: String.Encoding.utf8))!);
            let message : ObjectMessage = paserHelper.pareserModel(data: topicJson);
            
            if (state == .inactive){
                if screenPosition == AppDelegate.CHAT_GROUP_POSITION {
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_DETAIL_UPDATE, object: notification, userInfo: nil);
                    return;
                }
            }
            
            // message.type alway equal TypeMessage.Group.rawValue
            message.type = TypeMessage.Group.rawValue;
            self.showChat(message: message, notification: notification);
        } else if (type == "10") {
            //chat message
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: badge);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            
            let topic = userInfo["topic"] as? String;
            let topicJson = JSON(data: (topic?.data(using: String.Encoding.utf8))!);
            let paserHelper : ParserHelper = ParserHelper();
            let message : ObjectMessage = paserHelper.pareserModel(data: topicJson);
            
            if (state == .inactive){
                if (message.type ==  TypeMessage.Group.rawValue && screenPosition == AppDelegate.CHAT_GROUP_POSITION)
                 || (message.type ==  TypeMessage.OneToOne.rawValue && screenPosition == AppDelegate.CHAT_ONE_POSITION) {
                    return;
                }
                
            }
            
            self.showChat(message: message, notification: nil);
        } else if (type == "1") {
            //system
            let objSetTabbar = NotificationSetInfoBadgeTabbar(badge: badge);
            NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_SET_BADGE_TAB, object: objSetTabbar, userInfo: nil);
            
            let push = userInfo["data"] as? String;
            let pushJson = JSON(data: (push?.data(using: String.Encoding.utf8))!);
            let paserHelper : ParserHelper = ParserHelper();
            let notification : ObjectNotification = paserHelper.pareserModel(data: pushJson);
            
            if (state == .inactive){
                if (screenPosition == AppDelegate.PUSH_DETAIL_POSITION) {
                    NotificationCenter.default.post(name: Const.KEY_NOTIFICATION_DETAIL_UPDATE, object: notification, userInfo: nil);
                    return;
                }
            }
            
            self.showNotification(notification: notification);
        }
    }
    
    private func showNotification(notification: ObjectNotification) {
        let naviVC : UINavigationController;
        MainViewController.tabSelectedIndex = 3;
        NotificationViewController.visibleTabNotification = true;
        let mainVC = MainViewController();
        
        naviVC = UINavigationController(rootViewController: mainVC);
        
        self.window?.rootViewController = naviVC;
        self.window?.makeKeyAndVisible();
        
        let detailPushVC = DetailPushViewController();
        detailPushVC.objectNotification = notification;
        detailPushVC.callApi = !notification.isRead;
        
        mainVC.navigationController?.pushViewController(detailPushVC, animated: true);
    }
    
    private func showChat(message: ObjectMessage, notification : ObjectNotification!) {
        let naviVC : UINavigationController;
        MainViewController.tabSelectedIndex = 0;
        NotificationViewController.visibleTabNotification = false;
        let mainVC = MainViewController();
        
        naviVC = UINavigationController(rootViewController: mainVC);
        
        self.window?.rootViewController = naviVC;
        self.window?.makeKeyAndVisible();
        
        if (message.type ==  TypeMessage.Group.rawValue) {
            let topic: Topic = Topic(id: message.id!);
            let itemHome: ItemHome = ItemHome(user: User(), topic: topic);
            let chatVC = ChatGroupViewController();
            chatVC.isPressNotification = true;
            chatVC.notification = notification;
            chatVC.topicId = message.id;
            chatVC.itemHome = itemHome;
            
            naviVC.pushViewController(chatVC, animated: true);
            
        } else {
            let userAround: User = message.userAction!;
            let chatVC = ChatOneViewController();
            chatVC.isPressNotification = true;
            chatVC.userAround = userAround;
            naviVC.pushViewController(chatVC, animated: true);
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            NSLog("Message ID 1: \(messageID)")
        }
        
        // Print full message.
        var badge: Int = 0;
        if (notification.request.content.badge != nil) {
            badge = Int(notification.request.content.badge!);
            processNotification(userInfo: userInfo, badge: badge, isTapNotification: false);
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            NSLog("Message ID 2: \(messageID)")
        }
        
        // Print full message.
        var badge: Int = 0;
        if (response.notification.request.content.badge != nil) {
            badge = Int(response.notification.request.content.badge!);
            processNotification(userInfo: userInfo, badge: badge, isTapNotification: true);
        }
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        NSLog("\("remoteMessage.appData")")
    }
}
// [END ios_10_data_message_handling]

