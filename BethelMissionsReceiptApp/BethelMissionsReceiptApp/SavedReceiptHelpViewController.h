//
//  SavedReceiptHelpViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 23/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SavedHelpOverlayDelegate
@optional
-(void) onGotSavedHelpButton;

@end
@interface SavedReceiptHelpViewController : UIViewController
@property (weak,nonatomic) id <SavedHelpOverlayDelegate> savedHelpOverlayDelegate;
@end
