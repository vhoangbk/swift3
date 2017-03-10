//
//  AppDelegate.m
//  ApnsTest
//
//  Created by paraline on 3/9/17.
//  Copyright © 2017 paraline. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if(SYSTEM_VERSION_LESS_THAN( @"10.0" )) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else{
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error ) {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];
                 // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             } else {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//MARK: Push notifications delegades
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device token:%@",deviceTokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"APNS error:%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"Remote notification: %@",[userInfo description]);
 
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" )) {
//        [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result){}];
    } else {
        /// previous stuffs for iOS 9 and below. I've shown an alert wth received data.
    }
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    // iOS 10 will handle notifications through other methods
    
//    if( NOTIFY_VISITORS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
//    {
//        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
//        // set a member variable to tell the new delegate that this is background
//        return;
//    }
//    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
    // custom code to handle notification content
//    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
//    {
//        NSLog( @"INACTIVE" );
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
//    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
//    {
//        NSLog( @"BACKGROUND" );
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
//    else
//    {
//        NSLog( @"FOREGROUND" );
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
}

//- (void) registerAPNS : (UIApplication*) application{
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//        //iOS8以下
//        // リモート通知対象として登録する
//        [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|
//                                                          UIRemoteNotificationTypeSound|
//                                                          UIRemoteNotificationTypeAlert)];
//    }
////    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ){
////        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
////        center.delegate = self;
////        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
////            if(!error){
////                [[UIApplication sharedApplication] registerForRemoteNotifications];
////            }
////        }];
////    }
//    else{
//        
//        //iOS8以上
//        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
//        
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    }
//}

//Called when a notification is delivered to a foreground app.
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0) __TVOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0){
//    
//    NSLog(@"User Info : %@",notification.request.content.userInfo);
////    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
//}
//
////Called to let your app know which action was selected by the user for a given notification.
//// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler __IOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0) __TVOS_PROHIBITED{
//    
//    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
//    completionHandler();
//}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//    NSLog( @"Handle push from foreground" );
    // custom code to handle push while app is in the foreground
//    NSLog(@"%@", notification.request.content.userInfo);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
//    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
//    NSLog(@"%@", response.notification.request.content.userInfo);
}


@end
