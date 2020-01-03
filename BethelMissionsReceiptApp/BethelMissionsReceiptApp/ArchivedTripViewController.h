//
//  ArchivedTripViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/27/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@protocol LogoutDelegate
@optional
- (void)logout;
@end
@interface ArchivedTripViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (weak,nonatomic) id <LogoutDelegate> delegate;
@end
