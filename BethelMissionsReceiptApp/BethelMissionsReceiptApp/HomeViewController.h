//
//  HomeViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/9/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
#import "HelpScreenOverlayViewController.h"
#import "ArchivedTripViewController.h"
@interface HomeViewController : UIViewController<UIAlertViewDelegate,WebResponseClient,HelpOverlayDelegate,LogoutDelegate>
@property(nonatomic,strong) NSString * userName;
@end
