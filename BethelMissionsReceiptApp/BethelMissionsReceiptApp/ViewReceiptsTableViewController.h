//
//  ViewReceiptsTableViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/14/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
#import "Internet.h"
#import "ReceiptsContainerViewController.h"
@interface ViewReceiptsTableViewController : UITableViewController<UIAlertViewDelegate,WebResponseClient,UITableViewDelegate,SegmentAndUploadButtonDelegate>
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@end
