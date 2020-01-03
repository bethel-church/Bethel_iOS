//
//  MembersListViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 24/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
#import "AppDelegate.h"

@interface MembersListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,WebResponseClient>
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@end
