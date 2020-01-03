//
//  SettingsViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCurrenciesViewController.h"
#import "WebCalls.h"
@interface SettingsViewController : UIViewController<SelectedCurrenciesDelegate,WebResponseClient>
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@end
