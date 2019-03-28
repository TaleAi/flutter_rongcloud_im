//
//  RongCloudHandler.m
//  UZApp
//
//  Created by MiaoGuangfa on 1/20/15.
//  Copyright (c) 2015 APICloud. All rights reserved.
//

#import "RongCloudHandler.h"
#import <RongIMLib/RongIMLib.h>
#import "RongCloudApplicationHandler.h"


@implementation RongCloudHandler

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RongCloudApplicationHandler didApplicationFinishLaunchingWithOptions:launchOptions];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%s, deviceToken > %@", __FUNCTION__, deviceToken);
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                                               withString:@""]
                          stringByReplacingOccurrencesOfString:@">"
                          withString:@""]
                         stringByReplacingOccurrencesOfString:@" "
                         withString:@""];
    [RongCloudApplicationHandler didApplicationRegisterForRemoteNotificationsWithDeviceToken:token];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [RongCloudApplicationHandler didApplicationEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [RongCloudApplicationHandler willApplicationEnterForeground];
}
@end
