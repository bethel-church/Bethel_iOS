//
//  Internet.m
//  TwoFitApp
//
//  Created by Vivek Bhuria on 12/24/14.
//  Copyright (c) 2014 vDelve. All rights reserved.
//

#import "Internet.h"
#import "AppDelegate.h"
#import "Reachability.h"

#include<unistd.h>
#include<netdb.h>

@implementation Internet
+(void) addActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        UIWindow *appWindow = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        view.tag = 990099;
        view.backgroundColor = [UIColor clearColor];
        
        [appWindow addSubview:view];
        
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setFrame:CGRectMake(5, 5,30,30)];
        [activity startAnimating];
        
        UIView *activityBg = [[UIView alloc] initWithFrame:CGRectMake((appWindow.bounds.size.width - 40)/2, (appWindow.bounds.size.height - 40)/2, 40, 40)];
        activityBg.backgroundColor = [UIColor colorWithRed:93/256.0 green:111/256.0 blue:114/256.0 alpha:1.0];
        activityBg.layer.cornerRadius = 5.0;
        activityBg.tag = 1101101;
        [activityBg addSubview:activity];
        
        [appWindow addSubview:activityBg];
        [appWindow bringSubviewToFront:activity];
        [appWindow setUserInteractionEnabled:NO];
    });
    
}

+(void) removeActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIWindow *appWindow = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
        [[appWindow viewWithTag:1101101] removeFromSuperview];
        [[appWindow viewWithTag:990099] removeFromSuperview];
        [appWindow setUserInteractionEnabled:YES];
    });
    
}
//+(BOOL) isInternetAvailable
//{
//    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
//    if (networkStatus == NotReachable)
//    {
//        return NO;
//    }
//    else
//    {
//       return YES;
//    }
//}

+(BOOL)isInternetAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "betheltripreceipts.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        //NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
       // NSLog(@"-> connection established!\n");
        return YES;
    }
}
@end
