//
//  SecondCameraOverlayViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/17/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SecondOverlayDelegate
@optional
-(void) onRetake;
-(void)onAddSection;
-(void)onDone;
@end
@interface SecondCameraOverlayViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak,nonatomic) id <SecondOverlayDelegate> secondOverlayDelegate;
@end
