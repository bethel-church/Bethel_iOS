//
//  FirstCameraOverlayViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/17/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FirstOverlayDelegate
@optional
-(void) takePicutre;
-(void)onCancel;
-(void)onHelp;
@end
@interface FirstCameraOverlayViewController : UIViewController
@property(weak, nonatomic) id <FirstOverlayDelegate> firstOverlayDelegate;

@property (weak,nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIView *previousReceiptView;
-(void) showPreviousReceiptView:(UIImage*)previousReceiptImage sectionNumber:(NSInteger)section;
@end
