//
//  UserReceiptsListTableViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 25/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
#import "Internet.h"
@interface UserReceiptsListTableViewController : UITableViewController<WebResponseClient>
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@property (nonatomic, strong) NSDictionary *user;
@end
