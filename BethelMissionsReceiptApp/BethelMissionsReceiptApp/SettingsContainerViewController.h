//
//  SettingsContainerViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 23/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
@interface SettingsContainerViewController : UIViewController<WebResponseClient>
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@end
