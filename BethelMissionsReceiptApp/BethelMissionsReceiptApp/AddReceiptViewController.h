//
//  AddReceiptViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCurrencyViewController.h"
#import "ChooseCategoryViewController.h"
#import "FirstCameraOverlayViewController.h"
#import "SecondCameraOverlayViewController.h"
#import "HelpScreenOverlayViewController.h"
#import "WebCalls.h"
#import "Internet.h"
#import "AppDelegate.h"
#import "SavedReceiptHelpViewController.h"

@interface AddReceiptViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate,CurrencyDelegate,CategoryDelegate,FirstOverlayDelegate,SecondOverlayDelegate,HelpOverlayDelegate,WebResponseClient,UIAlertViewDelegate,SavedHelpOverlayDelegate>
@property (nonatomic,strong) NSString *mode;// Either "ADD" or "EDIT"
@property (nonatomic,strong) NSString *subMode;// Either "UPLOADED_RECEIPT" or "SAVED_RECEIPT". Pertains to "EDIT" mode only

@property (nonatomic,strong) NSDictionary *receipt;
@property (nonatomic,strong) NSManagedObject *currrentReceipt;
@property (nonatomic,weak) UIViewController *homeViewController;// for popping to home in case of archived trips.
@end
