//
//  ApnchatAppDelegate.m
//  Apnchat
//
//  Created by phylony on 12-12-22.
//  Copyright (c) 2012年 phylony. All rights reserved.
//

#import "ApnchatAppDelegate.h"

#import "ApnchatViewController.h"

#import "ASIFormDataRequest.h"

@implementation ApnchatAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ApnchatViewController alloc] initWithNibName:@"ApnchatViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    NSLog(@"%@",[self udid]);

    return YES;
}
-(NSString*)udid{
    UIDevice *device=[UIDevice   currentDevice];
    return [[device.identifierForVendor UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    NSLog(@"%@",[self udid]);
    
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@",
                                                                     [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    NSString *string=[deviceToken description];
    string  =[string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    string  =[string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Did register for remote notifications: %@", string);
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://www.uknown.net/ApnChat/api/api.php"]];
    [request setDelegate:self];
    [request setPostValue:@"join" forKey:@"cmd"];
    [request setPostValue:[self udid] forKey:@"udid"];
    [request setPostValue:string forKey:@"token"];
    [request setPostValue:@"AugCg" forKey:@"name"];
    [request setPostValue:@"12345" forKey:@"code"];
    [request setCompletionBlock:^{
        if (request.responseStatusCode!=200) {
            NSLog(@"Error");
        }else{
            NSLog(@"Joinder");
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"Failed");
    }];
    [request startAsynchronous];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
