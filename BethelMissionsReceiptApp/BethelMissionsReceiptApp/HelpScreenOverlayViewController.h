//
//  HelpScreenOverlayViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/6/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HelpOverlayDelegate
@optional
-(void) onGotIt;
-(void)onCancel;
@end
@interface HelpScreenOverlayViewController : UIViewController
@property (weak,nonatomic) id <HelpOverlayDelegate> helpOverlayDelegate;
-(void)showCheckButton:(BOOL)show;
@end
